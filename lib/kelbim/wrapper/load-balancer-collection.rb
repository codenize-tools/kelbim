require 'ostruct'
require 'kelbim/wrapper/load-balancer'
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
            :id           => '<new load balancer>',
            :name         => dsl.name,
            :vpc_id       => vpc,
            :instances    => dsl.instances,
            :scheme       => (dsl.internal ? 'internal' : 'internet-facing'),
            :listeners    => listeners,
            :health_check => {}, # health_checkはLoadBalancerの処理で更新
          })

          listeners.each do |lsnr|
            lsnr.load_balancer = lb

            if lsnr.server_certificate
              lsnr.server_certificate = OpenStruct.new(:name => lsnr.server_certificate)
            end
          end

          if vpc
            lb.subnets = dsl.subnets.map {|i| OpenStruct.new(:id => i) }
            sg_names = @options.security_group_names[vpc] || {}
            lb.security_group_ids = dsl.security_groups {|i| sg_names.key(i) || i }
          else
            lb.availability_zones = dsl.availability_zones.map {|i| OpenStruct.new(:name => i) }
          end
        else
          opts = {
            :scheme       => (dsl.internal ? 'internal' : 'internet-facing'),
            :listeners    => [],
          }

          opts[:instances] = dsl.instances unless dsl.instances.empty?

          dsl.listeners.each do |lsnr|
            lsnr_opts = {
              :port              => lsnr.port,
              :protocol          => lsnr.protocol,
              :instance_protocol => lsnr.instance_protocol,
              :instance_port     => lsnr.instance_port,
            }

            if (ss_name = lsnr.server_certificate)
              ss = @options.iam.server_certificates[ss_name]

              unless ss
                raise "Can't find ServerCertificate: #{ss_name} in #{vpc || :classic} > #{dsl.name}"
              end

              lsnr_opts[:server_certificate] = ss.arn
            end

            opts[:listeners] << lsnr_opts
          end

          if vpc
            opts[:subnets] = dsl.subnets.map {|i| AWS::EC2::Subnet.new(i) }
            sg_names = @options.security_group_names[vpc] || {}

            opts[:security_groups] = dsl.security_groups.map do |i|
              AWS::EC2::SecurityGroup.new(sg_names.key(i) || i)
            end
          else
            opts[:availability_zones] = dsl.availability_zones.map {|i|  AWS::EC2::SecurityGroup.new(:i) }
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
