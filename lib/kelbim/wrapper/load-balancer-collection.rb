require 'kelbim/wrapper/load-balancer'
require 'kelbim/logger'

module Kelbim
  class ELBWrapper
    class LoadBalancerCollection
      include Logger::ClientHelper

      def initialize(load_balancers, options)
        @load_balancers = load_balancers
        @options = options
      end

      def each
        @load_balancers.each do |lb|
          yield(LoadBalancer.new(lb, @options))
        end
      end

      def create(dsl, vpc)
        # XXX:
      end
    end # LoadBalancerCollection
  end # ELBWrapper
end # Kelbim
