require 'aws-sdk'

module AWS
  class ELB
    class Listener
      def policy_names
        _description[:policy_names]
      end

      def policies
        policy_names.map do |name|
          load_balancer.policies.find {|i| i.name == name }
        end
      end
    end # Listener
  end # ELB
end # AWS
