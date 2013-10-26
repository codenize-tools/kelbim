require 'aws-sdk'
require 'kelbim/dsl'
require 'kelbim/exporter'
require 'kelbim/ext/ec2-ext'

module Kelbim
  class Client
    def initialize(options = {})
      @options = OpenStruct.new(options)
      @options.elb = AWS::ELB.new
      @options.ec2 = AWS::EC2.new
    end

    def apply(file)
    end

    def export
      exported = nil
      instance_names = nil

      AWS.memoize do 
        exported = Exporter.export(@options.elb)
        instance_names = @options.ec2.instance_names
      end

      if block_given?
        converter = proc do |src|
          DSL.convert(src, instance_names)
        end

        yield(exported, converter)
      else
        DSL.convert(exported, instance_names)
      end
    end

    private
    def load_file(file)
      if file.kind_of?(String)
        open(file) do |f|
          DSL.define(f.read, file).result
        end
      elsif file.respond_to?(:read)
        DSL.define(file.read, file.path).result
      else
        raise TypeError, "can't convert #{file} into File"
      end
    end

    def walk(file)
      dsl = load_file(file)
    end
  end # Client
end # Piculet
