module Kelbim
  module PolicyTypes
    POLICIES = {
      :ssl_negotiation               => 'SSLNegotiationPolicyType',
      :app_cookie_stickiness         => 'AppCookieStickinessPolicyType',
      :lb_cookie_stickiness          => 'LBCookieStickinessPolicyType',
      :proxy_protocol                => 'ProxyProtocolPolicyType',
      #:backend_server_authentication => 'BackendServerAuthenticationPolicyType',
      #:public_key                    => 'PublicKeyPolicyType',
    }

    class << self
      def symbol_to_string(sym)
        str = POLICIES[sym]
        raise PolicyTypes "`#{sym}` is not supported" unless str
        return str
      end

      def string_to_symbol(str)
        sym = POLICIES.key(str)
        raise PolicyTypes "`#{str}` is not supported" unless sym
        return sym
      end
    end # of class methods
  end # PolicyTypes
end # Kelbim
