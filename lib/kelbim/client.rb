require 'aws-sdk'
require 'kelbim/dsl'
require 'kelbim/exporter'
require 'kelbim/ext/ec2-ext'
require 'kelbim/ext/elb-load-balancer-ext'
require 'kelbim/policy-types'
require 'kelbim/tester'
require 'kelbim/wrapper/elb-wrapper'
require 'kelbim/logger'

module Kelbim
  class Client
    include Logger::ClientHelper

    def initialize(options = {})
      @options = OpenStruct.new(options)
      @options.elb = AWS::ELB.new
      @options.ec2 = AWS::EC2.new
      @options.iam = AWS::IAM.new
    end

    def apply(file)
      AWS.memoize { walk(file) }
    end

    def test(file)
      AWS.memoize do
        dsl = load_file(file)
        Tester.test(dsl)
      end
    end

    def load_balancers
      exported = nil

      AWS.memoize do
        exported = Exporter.export(@options.elb)
      end

      retval = {}

      exported.map do |vpc, lbs|
        vpc = vpc || 'classic'
        retval[vpc] = {}

        lbs.map do |name, attrs|
          retval[vpc][name] = attrs[:dns_name]
        end
      end

      return retval
    end

    def export
      exported = nil
      instance_names = nil

      AWS.memoize do
        exported = Exporter.export(@options.elb)
        instance_names = @options.ec2.instance_names
      end

      if block_given?
        converter = proc do |src|
          DSL.convert(src, instance_names)
        end

        yield(exported, converter)
      else
        DSL.convert(exported, instance_names)
      end
    end

    private
    def load_file(file)
      if file.kind_of?(String)
        open(file) do |f|
          DSL.define(f.read, file).result
        end
      elsif file.respond_to?(:read)
        DSL.define(file.read, file.path).result
      else
        raise TypeError, "can't convert #{file} into File"
      end
    end

    def walk(file)
      dsl = load_file(file)

      dsl_ec2s = dsl.ec2s
      elb = ELBWrapper.new(@options.elb, @options)

      aws_ec2s = collect_to_hash(elb.load_balancers, :has_many => true) do |item|
        item.vpc_id
      end

      dsl_ec2s.each do |vpc, ec2_dsl|
        ec2_aws = aws_ec2s[vpc]

        if ec2_aws
          walk_ec2(vpc, ec2_dsl, ec2_aws, elb.load_balancers)
        else
          log(:warn, "EC2 `#{vpc || :classic}` is not found", :yellow)
        end
      end

      elb.updated?
    end

    def walk_ec2(vpc, ec2_dsl, ec2_aws, collection_api)
      lb_list_dsl = collect_to_hash(ec2_dsl.load_balancers, :name)
      lb_list_aws = collect_to_hash(ec2_aws, :name)

      lb_list_dsl.each do |key, lb_dsl|
        name = key[0]
        lb_aws = lb_list_aws[key]

        unless lb_aws
          lb_aws = collection_api.create(lb_dsl, vpc)
          lb_list_aws[key] = lb_aws
        end
      end

      lb_list_dsl.each do |key, lb_dsl|
        lb_aws = lb_list_aws.delete(key)
        walk_load_balancer(lb_dsl, lb_aws)
      end

      lb_list_aws.each do |key, lb_aws|
        lb_aws.delete
      end
    end

    def walk_load_balancer(load_balancer_dsl, load_balancer_aws)
      unless load_balancer_aws.eql?(load_balancer_dsl)
        load_balancer_aws.update(load_balancer_dsl)
      end

      lstnr_list_dsl = collect_to_hash(load_balancer_dsl.listeners, :port)
      listeners = load_balancer_aws.listeners
      lstnr_list_aws = collect_to_hash(listeners, :port)

      walk_listeners(lstnr_list_dsl, lstnr_list_aws, listeners)
    end

    def walk_listeners(listeners_dsl, listeners_aws, collection_api)
      listeners_dsl.each do |key, lstnr_dsl|
        lstnr_aws = listeners_aws[key]

        unless lstnr_aws
          lstnr_aws = collection_api.create(lstnr_dsl)
          listeners_aws[key] = lstnr_aws
        end
      end

      listeners_dsl.each do |key, lstnr_dsl|
        lstnr_aws = listeners_aws.delete(key)
        walk_listener(lstnr_dsl, lstnr_aws, collection_api)
      end

      listeners_aws.each do |key, lstnr_aws|
        lstnr_aws.delete
      end
    end

    def walk_listener(listener_dsl, listener_aws, collection_api)
      unless listener_aws.eql?(listener_dsl)
        if listener_aws.has_difference_protocol_port?(listener_dsl)
          listener_aws.delete
          listener_aws = collection_api.create(listener_dsl)
        else
          listener_aws.update(listener_dsl)
        end
      end

      plcy_list_dsl = collect_to_hash(listener_dsl.policies) do |policy_type, name_or_attrs|
        [PolicyTypes.symbol_to_string(policy_type)]
      end

      policies = listener_aws.policies
      plcy_list_aws = collect_to_hash(policies, :type)

      walk_policies(listener_aws, plcy_list_dsl, plcy_list_aws, policies)
    end

    def walk_policies(listener, policies_dsl, policies_aws, collection_api)
      orig_policy_names = policies_aws.map {|k, v| v.name }
      new_policies = []
      old_policies = []

      policies_dsl.each do |key, plcy_dsl|
        unless policies_aws[key]
          new_policies << collection_api.create(plcy_dsl)
        end
      end

      policies_dsl.each do |key, plcy_dsl|
        plcy_aws = policies_aws.delete(key)
        next unless plcy_aws

        if plcy_aws.eql?(plcy_dsl)
          new_policies << plcy_aws
        else
          new_policies << collection_api.create(plcy_dsl)
          old_policies << plcy_aws
        end
      end

      policies_aws.each do |key, plcy_aws|
        old_policies << plcy_aws
      end

      if not new_policies.empty? and orig_policy_names.sort != new_policies.map {|i| i.name }.sort
        listener.policies = new_policies

        unless @options.without_deleting_policy
          old_policies.each do |plcy_aws|
            plcy_aws.delete
          end
        end
      end
    end

    def collect_to_hash(collection, *key_attrs)
      options = key_attrs.last.kind_of?(Hash) ? key_attrs.pop : {}
      hash = {}

      collection.each do |item|
        key = block_given? ? yield(item) : key_attrs.map {|k| item.send(k) }

        if options[:has_many]
          hash[key] ||= []
          hash[key] << item
        else
          hash[key] = item
        end
      end

      return hash
    end
  end # Client
end # Kelbim
