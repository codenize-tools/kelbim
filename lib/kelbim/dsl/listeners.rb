require 'ostruct'
require 'kelbim/dsl/checker'
require 'kelbim/dsl/listener'

module Kelbim
  class DSL
    class EC2
      class LoadBalancer
        class Listeners
          include Checker

          def initialize(load_balancer, &block)
            @error_identifier = "LoadBalancer `#{load_balancer}`"
            @result = {}
            instance_eval(&block)
          end

          def result
            required(:listener, @result)

            @result.map do |protocol_ports, listener|
              protocol, port, instance_port, instance_protocol = protocol_ports.first.flatten

              OpenStruct.new({
                :protocol          => protocol,
                :port              => port,
                :instance_protocol => instance_protocol,
                :instance_port     => instance_port,
                :ssl_certificate   => listener.ssl_certificate,
                :policies          => listener.policies,
              })
            end
          end

          private
          def listener(protocol_ports, &block)
            expected_type(protocol_ports, Hash)
            expected_length(protocol_ports, 1)

            protocol_ports.first.each do |protocol_port|
              protocol, port = protocol_port
              expected_type(protocol_port, Array)
              expected_length(protocol_port, 2)
              expected_value(protocol, :http, :tcp)
              expected_type(port, Integer)
            end

            @result[protocol_ports] = Listener.new(@load_balancer, protocol_ports, &block).result
          end
        end # Listeners
      end # LoadBalancer
    end # EC2
  end # DSL
end # Kelbim
