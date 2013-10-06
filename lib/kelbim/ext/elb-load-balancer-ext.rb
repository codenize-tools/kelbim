require 'aws-sdk'

module AWS
  class ELB
    class LoadBalancer
      attribute :vpc_id, :static => true

      populates_from(:describe_load_balancers) do |resp|
        resp.data[:load_balancer_descriptions].find do |lb|
          lb[:load_balancer_name] == name
        end
      end
    end # LoadBalancer
  end # ELB
end # AWS
