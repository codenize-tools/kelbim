require 'ostruct'
require 'kelbim/wrapper/policy'
require 'kelbim/policy-types'
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
                # XXX: logging
                #log(:info, 'Create Policy', :cyan, "#{vpc || :classic} > #{dsl.name}")

                dsl_type, dsl_name_or_attrs = dsl

                #if @options.dry_run
                  plcy = OpenStruct.new({
                    :type => Kelbim::PolicyTypes.symbol_to_string(dsl_type),
                  })

                  if Kelbim::PolicyTypes.name?(dsl_name_or_attrs)
                    plcy.name == dsl_name_or_attrs
                  else
                    plcy.attributes = Kelbim::PolicyTypes.unexpand(dsl_type, dsl_name_or_attrs)
                  end
                #else
                #end

                Policy.new(plcy, @listener, @options)
                # XXX:
              end
            end # PolicyCollection
          end # Listener
        end # ListenerCollection
      end # LoadBalancer
    end # LoadBalancerCollection
  end # ELBWrapper
end # Kelbim
