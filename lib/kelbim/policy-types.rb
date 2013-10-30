module Kelbim
  module PolicyTypes
    POLICIES = {
      :ssl_negotiation               => 'SSLNegotiationPolicyType',
      :app_cookie_stickiness         => 'AppCookieStickinessPolicyType',
      :lb_cookie_stickiness          => 'LBCookieStickinessPolicyType',
      :proxy_protocol                => 'ProxyProtocolPolicyType',
      :backend_server_authentication => 'BackendServerAuthenticationPolicyType',
      :public_key                    => 'PublicKeyPolicyType',
    }

    EXPANDERS = {
      :ssl_negotiation => proc {|attrs|
        attrs.select {|name, value|
          value[0] =~ /\Atrue\Z/i
        }.map {|n, v| n }
      },
      :app_cookie_stickiness => proc {|attrs| attrs },
      :lb_cookie_stickiness => proc {|attrs| attrs },
      :proxy_protocol => proc {|attrs| attrs },
    }

    UNEXPANDERS = {
      :ssl_negotiation => proc {|attrs|
        unexpanded = {}

        attrs.each do |name|
          unexpanded[name] = ['true']
        end

        unexpanded
      },
    }

    class << self
      def symbol_to_string(sym)
        str = POLICIES[sym]
        raise "PolicyTypes `#{sym}` is not supported" unless str
        return str
      end

      def string_to_symbol(str)
        sym = POLICIES.key(str)
        raise "PolicyTypes `#{str}` is not supported" unless sym
        return sym
      end

      def convert_to_dsl(policy)
        policy_name = policy[:name]
        policy_type = policy[:type]
        policy_attrs = policy[:attributes]
        sym = string_to_symbol(policy_type)

        if (expander = EXPANDERS[sym])
          policy_attrs = expander.call(policy_attrs)

          if policy_attrs.kind_of?(Hash)
            new_policy_attrs = {}

            policy_attrs.each do |name, value|
              value = value[0] if value.length < 2
              new_policy_attrs[name] = value
            end

            args = new_policy_attrs.inspect.gsub(/\A\s*\{/, '').gsub(/\}\s*\Z/, '')
          else
            args = policy_attrs.inspect
          end
        else
          args = policy_name.inspect
        end

        "#{sym} #{args}"
      end

      def name?(name_or_attrs)
        name_or_attrs.kind_of?(String)
      end

      def expand(sym_or_str, policy_attrs)
        if sym_or_str.kind_of?(String)
          sym_or_str = string_to_symbol(sym_or_str)
        end

        expander = EXPANDERS[sym_or_str]
        expander ? expander.call(policy_attrs) : policy_attrs
      end

      def unexpand(sym_or_str, expanded_attrs)
        if sym_or_str.kind_of?(String)
          sym_or_str = string_to_symbol(sym_or_str)
        end

        unexpander = UNEXPANDERS[sym_or_str]
        unexpander ? unexpander.call(expanded_attrs) : expanded_attrs
      end
    end # of class methods
  end # PolicyTypes
end # Kelbim
