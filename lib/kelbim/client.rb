require 'aws-sdk'
require 'kelbim/dsl'
require 'kelbim/exporter'
require 'kelbim/ext/ec2-ext'
require 'kelbim/ext/elb-load-balancer-ext'
require 'kelbim/policy-types'
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

      lstnr_list_dsl = collect_to_hash(load_balancer_dsl.listeners, :protocol, :port, :instance_protocol, :instance_port)
      listeners = load_balancer_aws.listeners
      lstnr_list_aws = collect_to_hash(listeners, :protocol, :port, :instance_protocol, :instance_port)

      walk_listeners(lstnr_list_dsl, lstnr_list_aws, listeners)
    end

    def walk_listeners(listeners_dsl, listeners_aws, collection_api)
      listeners_dsl.each do |key, lstnr_dsl|
        lstnr_aws = listeners_aws[key]

        # XXX:
        #unless lstnr_aws
        #  lstnr_aws = collection_api.create(lstnr_dsl)
        #  listeners_aws[key] = lstnr_aws
        #end
      end

      listeners_dsl.each do |key, lstnr_dsl|
        lstnr_aws = listeners_aws.delete(key)
        walk_listener(lstnr_dsl, lstnr_aws)
      end

      listeners_aws.each do |key, lstnr_aws|
        lb_aws.delete
      end
    end

    def walk_listener(listener_dsl, listener_aws)
      unless listener_aws.eql?(listener_dsl)
        listener_aws.update(listener_dsl)
      end

      plcy_list_dsl = collect_to_hash(listener_dsl.policies) do |policy_type, name_or_attrs|
        [Kelbim::PolicyTypes.symbol_to_string(policy_type)]
      end

      policies = listener_aws.policies
      plcy_list_aws = collect_to_hash(policies, :type)

      walk_policies(plcy_list_dsl, plcy_list_aws, policies)
    end

    def walk_policies(policies_dsl, policies_aws, collection_api)
      policies_dsl.each do |key, plcy_dsl|
        plcy_aws = policies_aws[key]

        # XXX:
        #unless plcy_dsl
        #  plcy_aws = collection_api.create(name, plcy_dsl)
        #  policies_aws[key] = plcy_aws
        #end
      end

      policies_dsl.each do |key, plcy_dsl|
        plcy_aws = policies_aws.delete(key)
        walk_policy(plcy_dsl, plcy_aws)
      end

      policies_aws.each do |key, plcy_aws|
        lb_aws.delete
      end
    end

    def walk_policy(policy_dsl, policy_aws)
      unless policy_aws.eql?(policy_dsl)
        policy_aws.update(policy_aws)
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
