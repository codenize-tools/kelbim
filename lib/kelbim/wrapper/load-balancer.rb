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
          compare_health_check(dsl) or return false

          if self.vpc_id
            compare_subnet_ids(dsl) or return false
            compare_security_groups(dsl) or return false
          else
            compare_availability_zones(dsl) or return false
          end

          compare_instances(dsl)
        end

        def update(dsl)
          log(:info, 'Update LoadBalancer', :red, "#{self.vpc_id || :classic} > #{self.name}")

          compare_instances(dsl) do |aws_instance_ids, dsl_instance_ids|
            instance_names = @options.instance_names[self.vpc_id] || {}

            add_ids = (dsl_instance_ids - aws_instance_ids)

            unless add_ids.empty?
              # XXX: logging with name
              unless @options.dry_run
                @load_balancer.instances.register(*add_ids)
              end
            end

            del_ids = (aws_instance_ids - dsl_instance_ids)

            unless add_ids.empty?
              # XXX: logging with name
              unless @options.dry_run
                @load_balancer.instances.deregister(*del_ids)
              end
            end
          end

          compare_health_check(dsl) do
            # XXX: logging
            unless @options.dry_run
              @load_balancer.configure_health_check(dsl.health_check)
            end
          end

          if self.vpc_id
            compare_subnet_ids(dsl) do |aws_subnet_ids, dsl_subnet_ids|
              add_ids = (dsl_subnet_ids - aws_subnet_ids)

              unless add_ids.empty?
                # XXX: logging
                unless @options.dry_run
                  @options.elb.client.attach_load_balancer_to_subnets(
                    :load_balancer_name => @load_balancer.name,
                    :subnets => add_ids,
                  )
                end
              end

              del_ids = (aws_subnet_ids - dsl_subnet_ids)

              unless add_ids.empty?
                # XXX: logging
                unless @options.dry_run
                  @options.elb.client.attach_load_balancer_to_subnets(
                    :load_balancer_name => @load_balancer.name,
                    :subnets => add_ids,
                  )
                end
              end
            end

            compare_security_groups(dsl) do |dsl_sg_ids|
              sg_names = @options.security_group_names[self.vpc_id] || {}

              # XXX: logging with name
              unless @options.dry_run
                @options.elb.client.apply_security_groups_to_load_balancer(
                  :load_balancer_name => @load_balancer.name,
                  :security_groups => dsl_sg_ids,
                )
              end
            end
          else
            compare_availability_zones(dsl) do |aws_az_names, dsl_az_names|
              add_names = (dsl_az_names - aws_az_names)

              unless add_names.empty?
                # XXX: logging
                unless @options.dry_run
                  add_names.each do |az_name|
                    @load_balancer.availability_zones.enable(az_name)
                  end
                end
              end

              del_names = (aws_az_names - dsl_az_names)

              unless del_names.empty?
                # XXX: logging
                unless @options.dry_run
                  del_names.each do |az_name|
                    @load_balancer.availability_zones.disable(az_name)
                  end
                end
              end
            end
          end
        end

        def delete
          log(:info, 'Delete LoadBalancer', :red, "#{self.vpc_id || :classic} > #{self.name}")

          unless @options.dry_run
            @load_balancer.delete
            @options.updated = true
          end
        end

        private
        def compare_health_check(dsl)
          same = (@load_balancer.health_check.sort == dsl.health_check.sort)
          yield if !same && block_given?
          return same
        end

        def compare_subnet_ids(dsl)
          subnet_ids = @load_balancer.subnets.map {|i| i.id }
          same = (subnet_ids.sort == dsl.subnets.sort )
          yield(subnet_ids, dsl.subnets) if !same && block_given?
          return same
        end

        def compare_security_groups(dsl)
          aws_sg_ids = @load_balancer.security_group_ids.sort
          sg_names = @options.security_group_names[self.vpc_id] || {}

          dsl_sg_ids = dsl.security_groups.map {|i|
            sg_names.key(i) || i
          }.sort

          same = (aws_sg_ids == dsl_sg_ids)
          yield(dsl_sg_ids) if !same && block_given?
          return same
        end

        def compare_availability_zones(dsl)
          az_names = @load_balancer.availability_zones.map {|i| i.name }
          same = (az_names.sort == dsl.availability_zones.sort)
          yield(az_names, dsl.availability_zones) if !same && block_given?
          return same
        end

        def compare_instances(dsl)
          aws_instance_ids = @load_balancer.instances.map {|i| i.id }.sort

          dsl_instance_ids = dsl.instances.map {|i|
            instance_names = @options.instance_names[self.vpc_id] || {}
            instance_names.key(i) || i
          }.sort

          same = (aws_instance_ids == dsl_instance_ids)
          yield(aws_instance_ids, dsl_instance_ids) if !same && block_given?
          return same
        end
      end # LoadBalancer
    end # LoadBalancerCollection
  end # ELBWrapper
end # Kelbim
