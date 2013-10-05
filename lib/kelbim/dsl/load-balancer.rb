require 'ostruct'
require 'piculet/dsl/permissions'

module Kelbim
  class DSL
    class EC2
      class LoadBalancer
        def initialize(name, vpc, options, &block)
          @name = name
          @vpc = vpc

          @result = OpenStruct.new({
            :name      => name,
            :instances => [],
            :internal  => options[:internal],
          })
        end

        def result
          @result
        end

        # XXX: add test syntax

        def instances(*values)
          check_called(:instances)

          values = values.map do |instance_id_or_name|
            # XXX: name -> instance_id
            instance_id = instance_id_or_name

            if @result.instances.include?(instance_id)
              raise "LoadBalancer `#{@name}`: `#{instance_id_or_name}` is already included"
            end

            instance_id
          end

          @result.instances = values
        end

        def subnets(*values)
          check_called(:subnets)

          unless @vpc
            raise "LoadBalancer `#{@name}`: Subnet cannot be specified in EC2-Classic"
          end

          @result.subnets = values
        end

        def security_groups(*values)
          check_called(:security_groups)

          unless @vpc
            raise "LoadBalancer `#{@name}`: SecurityGroup cannot be specified in EC2-Classic"
          end

          values = values.map do |security_group_id_or_name|
            # XXX: name -> id
            security_group_id_or_name
          end

          @result.security_groups = values
        end

        def availability_zone(*values)
          check_called(:availability_zone)

          if @vpc
            raise "LoadBalancer `#{@name}`: SecurityGroup cannot be specified in EC2-VPC"
          end

          @result.availability_zone = values
        end

        private
        def check_called(method_name)
          @called ||= []

          if @called.include?[method_name]
            raise "LoadBalancer `#{@name}`: `#{method_name}` is already defined"
          end

          @called << method_name
        end
      end # LoadBalancer
    end # EC2
  end # DSL
end # Kelbim
