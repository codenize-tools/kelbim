require 'kelbim/wrapper/load-balancer-collection'
require 'kelbim/ext/ec2-ext'

module Kelbim
  class ELBWrapper
    def initialize(elb, options)
      @elb = elb
      @options = options.dup
      @options.instance_names = @options.ec2.instance_names
      @options.security_group_names = @options.ec2.security_group_names
    end

    def load_balancers
      LoadBalancerCollection.new(@elb.load_balancers, @options)
    end

    def updated?
      !!@options.updated
    end
  end # EC2Wrapper
end # Kelbim
