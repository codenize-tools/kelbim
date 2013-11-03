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
                  :name, :type)

                def initialize(policy, listener, options)
                  @policy = policy
                  @listener = listener
                  @options = options
                end

                def eql?(dsl)
                  dsl_type, dsl_name_or_attrs = dsl

                  if PolicyTypes.name?(dsl_name_or_attrs)
                    @policy.name == dsl_name_or_attrs
                  else
                    aws_attrs = PolicyTypes.expand(@policy.type, @policy.attributes)
                    aws_attrs.sort == dsl_name_or_attrs.sort
                  end
                end

                def delete
                  log(:info, 'Delete Policy', :red, "#{@listener.log_id} > #{self.name}")

                  unless @options.dry_run
                    @policy.delete
                    @options.updated = true
                  end
                end
              end # Policy
            end # PolicyCollection
          end # Listener
        end # ListenerCollection
      end # LoadBalancer
    end # LoadBalancerCollection
  end # ELBWrapper
end # Kelbim
