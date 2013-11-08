require 'ostruct'
require 'kelbim/dsl/checker'

module Kelbim
  class DSL
    class EC2
      class LoadBalancer
        class Attributes
          include Checker

          def initialize(load_balancer, &block)
            @error_identifier = "LoadBalancer `#{load_balancer}`"
            @result = {}
            instance_eval(&block)
          end

          def result
            required(:cross_zone_load_balancing, @result[:cross_zone_load_balancing])
            @result
          end

          def cross_zone_load_balancing(value)
            call_once(:cross_zone_load_balancing)
            expected_type(value, Hash)
            expected_length(value, 1)
            @result[:cross_zone_load_balancing] = value
          end
        end # Attributes
      end # LoadBalancer
    end # EC2
  end # DSL
end # Kelbim
