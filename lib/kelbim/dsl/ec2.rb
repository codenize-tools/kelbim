require 'ostruct'
require 'set'
require 'kelbim/dsl/load-balancer'

module Kelbim
  class DSL
    class EC2
      attr_reader :result

      def initialize(vpc, &block)
        @names = Set.new
        @result = OpenStruct.new({
          :vpc            => vpc,
          :load_balancers => [],
        })

        instance_eval(&block)
      end

      private
      def load_balancer(name, opts = {}, &block)
        if @names.include?(name)
          raise "EC2 `#{@result.vpc || :classic}`: `#{name}` is already defined"
        end

        unless (invalid_keys = (opts.keys - [:internal])).empty?
          raise "LoadBalancer `#{@name}`: Invalid option keys: #{invalid_keys}"
        end

        @result.load_balancers << LoadBalancer.new(name, @result.vpc, opts, &block).result
        @names << name
      end
    end # EC2
  end # DSL
end # Kelbim
