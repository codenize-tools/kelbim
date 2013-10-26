require 'ostruct'
require 'kelbim/dsl/converter'
require 'kelbim/dsl/ec2'

module Kelbim
  class DSL
    class << self
      def define(source, path)
        self.new(path) do
          eval(source, binding)
        end
      end

      def convert(exported, instance_names)
        Converter.convert(exported, instance_names)
      end
    end # of class methods

    attr_reader :result

    def initialize(path, &block)
      @path = path
      @result = OpenStruct.new(:ec2s => {})
      instance_eval(&block)
    end

    private
    def require(file)
      balancerfile = File.expand_path(File.join(File.dirname(@path), file))

      if File.exist?(balancerfile)
        instance_eval(File.read(balancerfile))
      elsif File.exist?(balancerfile + '.rb')
        instance_eval(File.read(balancerfile + '.rb'))
      else
        Kernel.require(file)
      end
    end

    def ec2(vpc = nil, &block)
      @result.ec2s[vpc] = EC2.new(vpc, &block).result
    end
  end # DSL
end # Kelbim
