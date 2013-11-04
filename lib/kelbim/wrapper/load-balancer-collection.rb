require 'ostruct'
require 'kelbim/wrapper/load-balancer'
require 'kelbim/wrapper/listener-collection'
require 'kelbim/logger'

module Kelbim
  class ELBWrapper
    class LoadBalancerCollection
      include Logger::ClientHelper

      def initialize(load_balancers, options)
        @load_balancers = load_balancers
        @options = options
      end

      def each
        @load_balancers.each do |lb|
          yield(LoadBalancer.new(lb, @options))
        end
      end

      def create(dsl, vpc)
        log(:info, 'Create LoadBalancer', :cyan, "#{vpc || :classic} > #{dsl.name}")

        if @options.dry_run
          listeners = dsl.listeners

          lb = OpenStruct.new({
            :id           => "<new load balancer name=#{dsl.name}>",
            :name         => dsl.name,
            :vpc_id       => vpc,
            :instances    => [], # instancesはLoadBalancerの処理で更新
            :scheme       => dsl.scheme,
            :listeners    => dsl.listeners.map {|i| LoadBalancer::ListenerCollection.create_mock_listener(i, @load_balancer) },
            :health_check => {}, # health_checkはLoadBalancerの処理で更新
          })

          if vpc
            lb.subnets = dsl.subnets.map {|i| OpenStruct.new(:id => i) }
            sg_names = @options.security_group_names[vpc] || {}
            lb.security_group_ids = dsl.security_groups {|i| sg_names.key(i) || i }
          else
            lb.availability_zones = dsl.availability_zones.map {|i| OpenStruct.new(:name => i) }
          end
        else
          opts = {
            :scheme    => dsl.scheme,
            :listeners => [],
          }

          # instancesはLoadBalancerの処理で更新

          dsl.listeners.each do |lstnr|
            lstnr_opts = LoadBalancer::ListenerCollection.create_listener_options(lstnr, @options.iam)
            opts[:listeners] << lstnr_opts
          end

          if vpc
            opts[:subnets] = dsl.subnets.map {|i| AWS::EC2::Subnet.new(i) }
            sg_names = @options.security_group_names[vpc] || {}

            opts[:security_groups] = dsl.security_groups.map do |i|
              AWS::EC2::SecurityGroup.new(sg_names.key(i) || i)
            end
          else
            opts[:availability_zones] = dsl.availability_zones.map {|i|  AWS::EC2::AvailabilityZone.new(i) }
          end

          # health_checkはLoadBalancerの処理で更新
          lb = @load_balancers.create(dsl.name, opts)
          @options.updated = true
        end

        LoadBalancer.new(lb, @options)
      end
    end # LoadBalancerCollection
  end # ELBWrapper
end # Kelbim
