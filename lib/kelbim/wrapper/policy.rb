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
                    if aws_attrs.is_a?(Hash)
                      aws_attrs.each do |name, value|
                        value = value[0] if value.length < 2
                        aws_attrs[name] = value
                      end
                    end
                    aws_attrs.sort == dsl_name_or_attrs.sort
                  end
                end

                def delete
                  log(:info, 'Delete Policy', :red, "#{@listener.log_id} > #{self.name}")

                  unless @options.dry_run
                    begin
                      @policy.delete
                      @options.updated = true
                    rescue AWS::ELB::Errors::InvalidConfigurationRequest => e
                      if e.message =~ /You cannot delete policy/
                        # nothing to do
                      else
                        raise e
                      end
                    end
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
