require 'ostruct'
require 'kelbim/wrapper/listener'
require 'kelbim/logger'

module Kelbim
  class ELBWrapper
    class LoadBalancerCollection
      class LoadBalancer
        class ListenerCollection
          include Logger::ClientHelper

          def initialize(listeners, load_balancer, options)
            @listeners = listeners
            @load_balancer = load_balancer
            @options = options
          end

          def each
            @listeners.each do |lstnr|
              yield(Listener.new(lstnr, @options))
            end
          end

          def create(dsl)
            # XXX: logging
            #log(:info, 'Create Listener', :cyan, "#{vpc || :classic} > #{dsl.name}")

            #if @options.dry_run
              lstnr = OpenStruct.new({
                :protocol          => dsl.protocol,
                :port              => dsl.port,
                :instance_protocol => dsl.instance_protocol,
                :instance_port     => dsl.instance_port,
              })

              if lstnr.server_certificate
                lstnr.server_certificate = OpenStruct.new(:name => lstnr.server_certificate)
              end
            #else
            #end


            Listener.new(lstnr, @options)
          end
        end # ListenerCollection
      end # LoadBalancer
    end # LoadBalancerCollection
  end # ELBWrapper
end # Kelbim
