require 'ostruct'
require 'kelbim/dsl/checker'
require 'kelbim/policy-types'

module Kelbim
  class DSL
    class EC2
      class LoadBalancer
        class Listeners
          class Listener
            include Checker

            def initialize(load_balancer, protocol_prots, &block)
              @protocol_prots = protocol_prots
              @error_identifier = "LoadBalancer `#{load_balancer}`: #{protocol_prots}"

              @result = OpenStruct.new({
                :policies => []
              })

              instance_eval(&block)
            end

            attr_reader :result

            def server_certificate(value)
              call_once(:server_certificate)
              @result.server_certificate = value
            end

            def policies(value)
              call_once(:policies)
              expected_type(value, Hash)

              unless value.kind_of?(Hash)
                raise "LoadBalancer `#{@load_balancer}`: #{@protocol_prots}: Invalid policies: #{value}"
              end

              value = value.map do |policy, name_or_attrs|
                expected_type(name_or_attrs, String, Hash)
                policy = PolicyTypes.symbol_to_string(policy)
                [policy, name_or_attrs]
              end

              @result.policies = value
            end
          end # Listener
        end # Listeners
      end # LoadBalancer
    end # EC2
  end # DSL
end # Kelbim
