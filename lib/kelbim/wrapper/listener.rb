require 'forwardable'
require 'kelbim/ext/elb-listener-ext'
require 'kelbim/wrapper/policy-collection'
require 'kelbim/logger'

module Kelbim
  class ELBWrapper
    class LoadBalancerCollection
      class LoadBalancer
        class ListenerCollection
          class Listener
            extend Forwardable
            include Logger::ClientHelper

            def_delegators(
              :@listener,
              :protocol, :port, :instance_protocol, :instance_port)

            def initialize(listener, options)
              @listener = listener
              @options = options
            end

            def policies
              PolicyCollection.new(@listener.policies, self, @options)
            end

            def eql?(dsl)
              aws_server_certificate = @listener.server_certificate
              aws_server_certificate = aws_server_certificate.name if aws_server_certificate
              aws_server_certificate == dsl.server_certificate
            end

            def update(dsl)
              # XXX:
            end

            def delete
              # XXX: ポリシーも削除（オプションで制御）
            end
          end # Listener
        end # ListenerCollection
      end # LoadBalancer
    end # LoadBalancerCollection
  end # ELBWrapper
end # Kelbim
