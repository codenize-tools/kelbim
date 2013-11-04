require File.expand_path("#{File.dirname __FILE__}/../spec_config")

describe Kelbim::Client do
  before do
    elbfile { (<<-EOS)
ec2 do
  load_balancer "my-load-balancer" do
    instances(
      "cthulhu",
      "hastur",
      "nyar",
      "yog"
    )

    listeners do
      listener [:http, 80] => [:http, 80] do
        lb_cookie_stickiness "CookieExpirationPeriod"=>"10"
      end
      listener [:https, 443] => [:http, 80] do
        app_cookie_stickiness "CookieName"=>"20"
        ssl_negotiation ["Protocol-TLSv1", "Protocol-SSLv3", "AES256-SHA", "DES-CBC3-SHA", "AES128-SHA", "RC4-SHA", "RC4-MD5"]
        server_certificate "test1"
      end
    end

    health_check do
      target "HTTP:80/index.html"
      timeout 5
      interval 30
      healthy_threshold 10
      unhealthy_threshold 2
    end

    availability_zones(
      "us-west-1a",
      "us-west-1b",
      "us-west-1c"
    )
  end
end

ec2 "vpc-c1cbc2a3" do
  load_balancer "my-load-balancer-1" do
    instances(
      "cthulhu",
      "hastur",
      "nyar",
      "yog"
    )

    listeners do
      listener [:tcp, 8080] => [:tcp, 8080]
      listener [:https, 443] => [:http, 80] do
        lb_cookie_stickiness "CookieExpirationPeriod"=>"11"
        ssl_negotiation ["Protocol-TLSv1", "Protocol-SSLv3", "AES256-SHA", "DES-CBC3-SHA", "AES128-SHA", "RC4-SHA", "RC4-MD5"]
        server_certificate "test2"
      end
    end

    health_check do
      target "TCP:8080"
      timeout 5
      interval 30
      healthy_threshold 10
      unhealthy_threshold 2
    end

    subnets(
      "subnet-5e1c153c",
      "subnet-567c3610",
    )

    security_groups(
      "default",
      "vpc-c1cbc2a3-1",
      "vpc-c1cbc2a3-2"
    )
  end
end

ec2 "vpc-cbcbc2a9" do
  load_balancer "my-load-balancer-2", :internal => true do
    instances(
      "cthulhu",
      "hastur",
      "nyar",
      "yog"
    )

    listeners do
      listener [:http, 80] => [:http, 80] do
        lb_cookie_stickiness "CookieExpirationPeriod"=>"12"
      end
      listener [:https, 443] => [:http, 80] do
        app_cookie_stickiness "CookieName"=>"22"
        ssl_negotiation ["Protocol-TLSv1", "Protocol-SSLv3", "AES256-SHA", "DES-CBC3-SHA", "AES128-SHA", "RC4-SHA", "RC4-MD5"]
        server_certificate "test3"
      end
    end

    health_check do
      target "HTTP:80/index.html"
      timeout 5
      interval 30
      healthy_threshold 10
      unhealthy_threshold 2
    end

    subnets(
      "subnet-211c1543",
      "subnet-487c360e",
    )

    security_groups(
      "default",
      "vpc-cbcbc2a9-1",
      "vpc-cbcbc2a9-2"
    )
  end
end
      EOS
    }
  end

  it do
    policies = elbfile(:mode => :show_policies) { '' }
    new_policies = {}

    policies.each do |vpc, elbs|
      new_policies[vpc] ||= {}

      elbs.each do |elb_name, elb_policies|
        new_policies[vpc][elb_name] ||= {}

        elb_policies.each do |policy_name, policy_type|
          policy_name = policy_name.sub(
            /\w+-\w+-\w+-\w+-\w+\Z/,
            'XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX')

          new_policies[vpc][elb_name][policy_name] = policy_type
        end
      end
    end

    expect(new_policies).to eq(
{"classic"=>
  {"my-load-balancer"=>
    {"classic-my-load-balancer-https-443-http-80-AppCookieStickinessPolicyType-XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX"=>
      "AppCookieStickinessPolicyType",
     "classic-my-load-balancer-http-80-http-80-LBCookieStickinessPolicyType-XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX"=>
      "LBCookieStickinessPolicyType",
     "classic-my-load-balancer-https-443-http-80-SSLNegotiationPolicyType-XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX"=>
      "SSLNegotiationPolicyType"}},
 "vpc-c1cbc2a3"=>
  {"my-load-balancer-1"=>
    {"vpc-c1cbc2a3-my-load-balancer-1-https-443-http-80-LBCookieStickinessPolicyType-XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX"=>
      "LBCookieStickinessPolicyType",
     "vpc-c1cbc2a3-my-load-balancer-1-https-443-http-80-SSLNegotiationPolicyType-XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX"=>
      "SSLNegotiationPolicyType"}},
 "vpc-cbcbc2a9"=>
  {"my-load-balancer-2"=>
    {"vpc-cbcbc2a9-my-load-balancer-2-http-80-http-80-LBCookieStickinessPolicyType-XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX"=>
      "LBCookieStickinessPolicyType",
     "vpc-cbcbc2a9-my-load-balancer-2-https-443-http-80-SSLNegotiationPolicyType-XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX"=>
      "SSLNegotiationPolicyType",
     "vpc-cbcbc2a9-my-load-balancer-2-https-443-http-80-AppCookieStickinessPolicyType-XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX"=>
      "AppCookieStickinessPolicyType"}}}
    )
  end
end
