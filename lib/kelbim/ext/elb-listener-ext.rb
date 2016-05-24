require 'aws-sdk'

module AWS
  class ELB
    class Listener
      def policy_names
        _description[:policy_names]
      end

      def policies
        if AWS.memoizing? and @policy_list
          return @policy_list
        end

        @policy_list = policy_names.map do |name|
          load_balancer.policies.find {|i| i.name == name }
        end
      end

      def ssl_certificate_id
        _description[:listener][:ssl_certificate_id]
      end

      def ssl_certificate_id=(arn)
        client.set_load_balancer_listener_ssl_certificate(
          :load_balancer_name => load_balancer.name,
          :load_balancer_port => port,
          :ssl_certificate_id => arn)
        nil
      end
    end # Listener
  end # ELB
end # AWS
