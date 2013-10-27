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
    end # Listener
  end # ELB
end # AWS
