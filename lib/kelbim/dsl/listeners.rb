module Kelbim
  class DSL
    class EC2
      class LoadBalancer
        class Listeners
          include Checker
          include Kelbim::TemplateHelper

          def initialize(context, load_balancer, &block)
            @error_identifier = "LoadBalancer `#{load_balancer}`"
            @context = context.dup
            @result = {}
            instance_eval(&block)
          end

          def result
            required(:listener, @result)

            @result.map do |protocol_ports, listener|
              protocol, port, instance_protocol, instance_port = protocol_ports.first.flatten

              OpenStruct.new({
                :protocol           => protocol,
                :port               => port,
                :instance_protocol  => instance_protocol,
                :instance_port      => instance_port,
                :server_certificate => listener.server_certificate,
                :policies           => listener.policies,
              })
            end
          end

          private
          def listener(protocol_ports, &block)
            expected_type(protocol_ports, Hash)
            expected_length(protocol_ports, 1)

            block = proc {} unless block

            protocol_ports.first.each do |protocol_port|
              protocol, port = protocol_port
              expected_type(protocol_port, Array)
              expected_length(protocol_port, 2)
              expected_value(protocol, :http, :https, :tcp, :ssl)
              expected_type(port, Integer)
            end

            @result[protocol_ports] = Listener.new(@context, @load_balancer, protocol_ports, &block).result
          end
        end # Listeners
      end # LoadBalancer
    end # EC2
  end # DSL
end # Kelbim
