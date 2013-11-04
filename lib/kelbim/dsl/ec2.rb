require 'ostruct'
require 'set'
require 'kelbim/dsl/load-balancer'

module Kelbim
  class DSL
    class EC2
      attr_reader :result

      def initialize(vpc, load_balancers, &block)
        @error_identifier = "EC2 `#{vpc || :classic}`"

        @result = OpenStruct.new({
          :vpc            => vpc,
          :load_balancers => load_balancers,
        })

        @names = load_balancers.map {|i| i.name }
        instance_eval(&block)
      end

      private
      def load_balancer(name, opts = {}, &block)
        if @names.include?(name)
          raise "#{@error_identifier}: `#{name}` is already defined"
        end

        unless (invalid_keys = (opts.keys - [:internal])).empty?
          raise "LoadBalancer `#{name}`: Invalid option keys: #{invalid_keys}"
        end

        @result.load_balancers << LoadBalancer.new(name, @result.vpc, opts[:internal], &block).result
        @names << name
      end
    end # EC2
  end # DSL
end # Kelbim
