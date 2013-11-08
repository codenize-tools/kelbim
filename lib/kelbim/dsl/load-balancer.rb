require 'ostruct'
require 'kelbim/dsl/checker'
require 'kelbim/dsl/health-check'
require 'kelbim/dsl/attributes'
require 'kelbim/dsl/listeners'

module Kelbim
  class DSL
    class EC2
      class LoadBalancer
        include Checker

        def initialize(name, vpc, internal, &block)
          @name = name
          @vpc = vpc
          @error_identifier = "LoadBalancer `#{name}`"

          @result = OpenStruct.new({
            :name      => name,
            :instances => [],
            :internal  => internal,
            :scheme    => internal ? 'internal' : 'internet-facing',
          })

          instance_eval(&block)
        end

        def result
          required(:listeners, @result.listeners)
          required(:health_check, @result.health_check)
          #required(:attributes, @result.attributes)

          if @vpc
            required(:subnets, @result.subnets)
            required(:security_groups, @result.security_groups)
          else
            required(:availability_zones, @result.availability_zones)
          end

          @result
        end

        def spec(&block)
          call_once(:spec)
          @result.spec = block
        end

        def instances(*values)
          call_once(:instances)

          values.each do |instance_id_or_name|
            instance_id = instance_id_or_name
            not_include(instance_id_or_name, @result.instances)
            @result.instances << instance_id
          end
        end

        def listeners(&block)
          call_once(:listeners)
          @result.listeners = Listeners.new(@name, &block).result
        end

        def health_check(&block)
          call_once(:health_check)
          @result.health_check = HealthCheck.new(@name, &block).result
        end

        def attributes(&block)
          call_once(:attributes)
          @result.attributes = Attributes.new(@name, &block).result
        end

        def subnets(*values)
          call_once(:subnets)
          raise "#{@error_identifier}: Subnet cannot be specified in EC2-Classic" unless @vpc
          @result.subnets = values
        end

        def security_groups(*values)
          call_once(:security_groups)
          raise "#{@error_identifier}: SecurityGroup cannot be specified in EC2-Classic" unless @vpc
          @result.security_groups = values
        end

        def availability_zones(*values)
          call_once(:availability_zone)
          raise "#{@error_identifier}: SecurityGroup cannot be specified in EC2-VPC" if @vpc
          @result.availability_zones = values
        end
      end # LoadBalancer
    end # EC2
  end # DSL
end # Kelbim
