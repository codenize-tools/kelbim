module Kelbim
  class DSL
    class EC2
      class LoadBalancer
        class HealthCheck
          include Checker

          def initialize(load_balancer, &block)
            @error_identifier = "LoadBalancer `#{load_balancer}`"
            @result = {}
            instance_eval(&block)
          end

          def result
            [:target, :timeout, :interval, :healthy_threshold, :unhealthy_threshold].each do |name|
              required(name, @result[name])
            end

            @result
          end

          def target(value)
            call_once(:target)
            @result[:target] = value
          end

          def timeout(value)
            call_once(:timeout)
            expected_type(value, Integer)
            @result[:timeout] = value
          end

          def interval(value)
            call_once(:interval)
            expected_type(value, Integer)
            @result[:interval] = value
          end

          def healthy_threshold(value)
            call_once(:healthy_threshold)
            expected_type(value, Integer)
            @result[:healthy_threshold] = value
          end

          def unhealthy_threshold(value)
            call_once(:unhealthy_threshold)
            expected_type(value, Integer)
            @result[:unhealthy_threshold] = value
          end
        end # HealthCheck
      end # LoadBalancer
    end # EC2
  end # DSL
end # Kelbim
