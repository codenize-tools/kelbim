module Kelbim
  class DSL
    include Kelbim::TemplateHelper

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

      @context = Hashie::Mash.new(
        :path => path,
        :templates => {}
      )

      instance_eval(&block)
    end

    private

    def require(file)
      balancerfile = (file =~ %r|\A/|) ? file : File.expand_path(File.join(File.dirname(@path), file))

      if File.exist?(balancerfile)
        instance_eval(File.read(balancerfile), balancerfile)
      elsif File.exist?(balancerfile + '.rb')
        instance_eval(File.read(balancerfile + '.rb'), balancerfile + '.rb')
      else
        Kernel.require(file)
      end
    end

    def template(name, &block)
      @context.templates[name.to_s] = block
    end

    def ec2(vpc = nil, &block)
      if (ec2_result = @result.ec2s[vpc])
        @result.ec2s[vpc] = EC2.new(@context, vpc, ec2_result.load_balancers, &block).result
      else
        @result.ec2s[vpc] = EC2.new(@context, vpc, [], &block).result
      end
    end
  end # DSL
end # Kelbim
