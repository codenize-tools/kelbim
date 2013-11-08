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

      def attributes
        unless @attributes
          credentials = AWS.config.credential_provider.credentials
          elb = AWS::ELB.new(credentials)
          @attributes = elb.client.describe_load_balancer_attributes(
            :load_balancer_name => self.name).data
        end

        return @attributes.dup
      end

      def attributes=(attrs)
        credentials = AWS.config.credential_provider.credentials
        elb = AWS::ELB.new(credentials)

        elb.client.modify_load_balancer_attributes({
          :load_balancer_name       => self.name,
          :load_balancer_attributes => attrs,
        })

        (@attributes = attrs).dup
      end
    end # LoadBalancer
  end # ELB
end # AWS
