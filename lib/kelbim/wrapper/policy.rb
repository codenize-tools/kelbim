require 'forwardable'
require 'kelbim/policy-types'
require 'kelbim/logger'

module Kelbim
  class ELBWrapper
    class LoadBalancerCollection
      class LoadBalancer
        class ListenerCollection
          class Listener
            class PolicyCollection
              class Policy
                extend Forwardable
                include Logger::ClientHelper

                def_delegators(
                  :@policy,
                  :type)

                def initialize(policy, listener, options)
                  @policy = policy
                  @listener = listener
                  @options = options
                end

                def eql?(dsl)
                  dsl_type, dsl_name_or_attrs = dsl

                  if Kelbim::PolicyTypes.name?(dsl_name_or_attrs)
                    @policy.name == dsl_name_or_attrs
                  else
                    aws_attrs = Kelbim::PolicyTypes.expand(@policy.type, @policy.attributes)
                    aws_attrs.sort == dsl_name_or_attrs.sort
                  end
                end

                def update(dsl)
                  # XXX:
                end

                def delete
                  # XXX:
                end
              end # Policy
            end # PolicyCollection
          end # Listener
        end # ListenerCollection
      end # LoadBalancer
    end # LoadBalancerCollection
  end # ELBWrapper
end # Kelbim
