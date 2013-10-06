require 'kelbim/ext/elb-load-balancer-ext'

module Kelbim
  class Exporter
    class << self
      def export(elb)
        self.new(elb).export
      end
    end # of class methods

    def initialize(elb)
      @elb = elb
    end

    def export
      result = {}

      @elb.load_balancers.each do |lb|
        result[lb.vpc_id] ||= {}
        result[lb.vpc_id][lb.name] = export_load_balancer(lb)
      end

      return result
    end

    private
    def export_load_balancer(load_balancer)
      attrs = {
        :instances    => load_balancer.instances.map {|i| i.tags['Name'] || i.id },
        :listeners    => export_listeners(load_balancer.listeners),
        :health_check => load_balancer.health_check,
        :scheme       => load_balancer.scheme,
        :dns_name     => load_balancer.dns_name,
      }

      if load_balancer.vpc_id
        attrs[:subnets] = load_balancer.subnets.map {|i| i.id }
        attrs[:security_groups] = load_balancer.security_groups.map {|i| i.name }
      else
        attrs[:availability_zones] = load_balancer.availability_zones.map {|i| i.name }
      end

      return attrs
    end

    def export_listeners(listeners)
      # XXX:
      listeners
    end
  end # Exporter
end # Kelbim
