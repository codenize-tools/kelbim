require 'kelbim/wrapper/policy'
require 'kelbim/logger'

module Kelbim
  class ELBWrapper
    class LoadBalancerCollection
      class LoadBalancer
        class ListenerCollection
          class Listener
            class PolicyCollection
              include Logger::ClientHelper

              def initialize(policies, listener, options)
                @policies = policies
                @listener = listener
                @options = options
              end

              def each
                @policies.each do |plcy|
                  yield(Policy.new(plcy, @listener, @options))
                end
              end

              def create(dsl)
                # XXX:
              end
            end # PolicyCollection
          end # Listener
        end # ListenerCollection
      end # LoadBalancer
    end # LoadBalancerCollection
  end # ELBWrapper
end # Kelbim
