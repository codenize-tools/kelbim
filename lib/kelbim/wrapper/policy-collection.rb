require 'ostruct'
require 'kelbim/wrapper/policy'
require 'kelbim/policy-types'
require 'kelbim/logger'
require 'uuid'

module Kelbim
  class ELBWrapper
    class LoadBalancerCollection
      class LoadBalancer
        class ListenerCollection
          class Listener
            class PolicyCollection
              include Logger::ClientHelper

              class << self
                def create_mock_policy(dsl)
                  dsl_type, dsl_name_or_attrs = dsl
                  policy_type = PolicyTypes.symbol_to_string(dsl_type)
                  plcy = OpenStruct.new(:type => policy_type)

                  if PolicyTypes.name?(dsl_name_or_attrs)
                    plcy.name = dsl_name_or_attrs
                    plcy.attribute = {'<new policy attribute name>' => ['<new policy attribute value>']}
                  else
                    plcy.name = '<new policy name>'
                    plcy.attributes = PolicyTypes.unexpand(dsl_type, dsl_name_or_attrs)
                  end

                  return plcy
                end
              end # of class methods

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
                dsl_type, dsl_name_or_attrs = dsl
                log_id = "#{@listener.load_balancer.vpc_id || :classic} > #{@listener.load_balancer.name} > #{PolicyTypes.symbol_to_string(dsl_type)}: "
                log_id += PolicyTypes.name?(dsl_name_or_attrs) ? dsl_name_or_attrs : dsl_name_or_attrs.inspect
                log(:info, 'Create Policy', :cyan, log_id)

                plcy = @options.dry_run ? self.class.create_mock_policy(dsl) : create_policy(dsl)
                Policy.new(plcy, @listener, @options)
              end

              private
              def create_policy(dsl)
                dsl_type, dsl_name_or_attrs = dsl
                policy_type = PolicyTypes.symbol_to_string(dsl_type)

                if PolicyTypes.name?(dsl_name_or_attrs)
                  plcy = @listener.load_balancer.policies[dsl_name_or_attrs]

                  unless plcy
                    raise "Can't find Policy: #{dsl_name_or_attrs} in #{@listener.load_balancer.vpc_id || :classic} > #{@listener.load_balancer.name}"
                  end
                else
                  policy_name = [
                    @listener.load_balancer.vpc_id || :classic,
                    @listener.load_balancer.name,
                    @listener.protocol,
                    @listener.port,
                    @listener.instance_protocol,
                    @listener.instance_port,
                    policy_type,
                    UUID.new.generate,
                  ].join('-').gsub(/\s/, '_')

                  plcy = @listener.load_balancer.policies.create(
                    policy_name,
                    policy_type,
                    PolicyTypes.unexpand(dsl_type, dsl_name_or_attrs)
                  )
                end

                @options.updated = true

                return plcy
              end
            end # PolicyCollection
          end # Listener
        end # ListenerCollection
      end # LoadBalancer
    end # LoadBalancerCollection
  end # ELBWrapper
end # Kelbim
