require 'forwardable'
require 'kelbim/wrapper/listener-collection'
require 'kelbim/logger'

module Kelbim
  class ELBWrapper
    class LoadBalancerCollection
      class LoadBalancer
        extend Forwardable
        include Logger::ClientHelper

        def_delegators(
          :@load_balancer,
          :vpc_id, :name)

        def initialize(load_balancer, options)
          @load_balancer = load_balancer
          @options = options
        end

        def listeners
          ListenerCollection.new(@load_balancer.listeners, self, @options)
        end

        def eql?(dsl)
          @load_balancer.health_check.sort == dsl.health_check.sort or return false

          if self.vpc_id
            subnet_ids = @load_balancer.subnets.map {|i| i.id }
            subnet_ids.sort == dsl.subnets.sort or return false

            aws_sg_ids = @load_balancer.security_group_ids.sort
            sg_names = @options.security_group_names[self.vpc_id] || {}

            dsl_sg_ids = dsl.security_groups.map {|i|
              sg_names.key(i) || i
            }.sort

            aws_sg_ids == dsl_sg_ids or return false
          else
            az_names = @load_balancer.availability_zones.map {|i| i.name }
            az_names.sort == dsl.availability_zones.sort or return false
          end  

          aws_instance_ids = @load_balancer.instances.map {|i| i.id }.sort

          dsl_instance_ids = dsl.instances.map {|i|
            instance_names = @options.instance_names[self.vpc_id] || {}
            instance_names.key(i) || i
          }.sort

          aws_instance_ids == dsl_instance_ids
        end

        def update(dsl)
          log(:info, 'Update LoadBalancer', :red, "#{self.vpc_id || :classic} > #{self.name}")
          # XXX:
        end

        def delete
          log(:info, 'Delete LoadBalancer', :red, "#{self.vpc_id || :classic} > #{self.name}")

          unless @options.dry_run
            @load_balancer.delete
            @options.updated = true
          end
        end
      end # LoadBalancer
    end # LoadBalancerCollection
  end # ELBWrapper
end # Kelbim
