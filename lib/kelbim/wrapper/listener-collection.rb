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
            # XXX:
          end
        end # ListenerCollection
      end # LoadBalancer
    end # LoadBalancerCollection
  end # ELBWrapper
end # Kelbim
