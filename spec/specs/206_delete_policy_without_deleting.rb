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
    updated = elbfile(:without_deleting_policy => true) { (<<-EOS)
ec2 do
  load_balancer "my-load-balancer" do
    instances(
      "cthulhu",
      "hastur",
      "nyar",
      "yog"
    )

    listeners do
      listener [:http, 80] => [:http, 80]
      listener [:https, 443] => [:http, 80] do
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
      listener [:http, 80] => [:http, 80]
      listener [:https, 443] => [:http, 80] do
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

    expect(updated).to be_true
    exported = export_elb
    expect(exported).to eq(
{nil=>
  {"my-load-balancer"=>
    {:instances=>["i-5cf2c707", "i-5df2c706", "i-6097f23a", "i-6197f23b"],
     :listeners=>
      [{:protocol=>:http,
        :port=>80,
        :instance_protocol=>:http,
        :instance_port=>80,
        :server_certificate=>nil,
        :policies=>[]},
       {:protocol=>:https,
        :port=>443,
        :instance_protocol=>:http,
        :instance_port=>80,
        :server_certificate=>"test1",
        :policies=>[]}],
     :health_check=>
      {:interval=>30,
       :target=>"HTTP:80/index.html",
       :healthy_threshold=>10,
       :timeout=>5,
       :unhealthy_threshold=>2},
     :scheme=>"internet-facing",
     :attributes=>{:cross_zone_load_balancing=>{:enabled=>false}},
     :dns_name=>"my-load-balancer-NNNNNNNNNN.us-west-1.elb.amazonaws.com",
     :availability_zones=>["us-west-1a", "us-west-1b", "us-west-1c"]}},
 "vpc-c1cbc2a3"=>
  {"my-load-balancer-1"=>
    {:instances=>["i-a89605f3", "i-a99605f2", "i-e15739bb", "i-e65739bc"],
     :listeners=>
      [{:protocol=>:https,
        :port=>443,
        :instance_protocol=>:http,
        :instance_port=>80,
        :server_certificate=>"test2",
        :policies=>[]},
       {:protocol=>:tcp,
        :port=>8080,
        :instance_protocol=>:tcp,
        :instance_port=>8080,
        :server_certificate=>nil,
        :policies=>[]}],
     :health_check=>
      {:interval=>30,
       :target=>"TCP:8080",
       :healthy_threshold=>10,
       :timeout=>5,
       :unhealthy_threshold=>2},
     :scheme=>"internet-facing",
     :attributes=>{:cross_zone_load_balancing=>{:enabled=>false}},
     :dns_name=>"my-load-balancer-1-NNNNNNNNNN.us-west-1.elb.amazonaws.com",
     :subnets=>["subnet-567c3610", "subnet-5e1c153c"],
     :security_groups=>["default", "vpc-c1cbc2a3-1", "vpc-c1cbc2a3-2"]}},
 "vpc-cbcbc2a9"=>
  {"my-load-balancer-2"=>
    {:instances=>["i-0f6e1f54", "i-1c953346", "i-1f953345", "i-8b5120d0"],
     :listeners=>
      [{:protocol=>:http,
        :port=>80,
        :instance_protocol=>:http,
        :instance_port=>80,
        :server_certificate=>nil,
        :policies=>[]},
       {:protocol=>:https,
        :port=>443,
        :instance_protocol=>:http,
        :instance_port=>80,
        :server_certificate=>"test3",
        :policies=>[]}],
     :health_check=>
      {:interval=>30,
       :target=>"HTTP:80/index.html",
       :healthy_threshold=>10,
       :timeout=>5,
       :unhealthy_threshold=>2},
     :scheme=>"internal",
     :attributes=>{:cross_zone_load_balancing=>{:enabled=>false}},
     :dns_name=>
      "internal-my-load-balancer-2-NNNNNNNNNN.us-west-1.elb.amazonaws.com",
     :subnets=>["subnet-211c1543", "subnet-487c360e"],
     :security_groups=>["default", "vpc-cbcbc2a9-1", "vpc-cbcbc2a9-2"]}}}
    )

    with_elb do |elb|
      my_load_balancer_policies = get_policy_names(elb, 'my-load-balancer')
      expect(my_load_balancer_policies).to eq([
        "classic-my-load-balancer-http-80-http-80-LBCookieStickinessPolicyType-XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX",
        "classic-my-load-balancer-https-443-http-80-AppCookieStickinessPolicyType-XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX",
        "classic-my-load-balancer-https-443-http-80-SSLNegotiationPolicyType-XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX",
      ])

      my_load_balancer_1_policies = get_policy_names(elb, 'my-load-balancer-1')
      expect(my_load_balancer_1_policies).to eq([
        "vpc-c1cbc2a3-my-load-balancer-1-https-443-http-80-LBCookieStickinessPolicyType-XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX",
        "vpc-c1cbc2a3-my-load-balancer-1-https-443-http-80-SSLNegotiationPolicyType-XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX",
      ])

      my_load_balancer_2_policies = get_policy_names(elb, 'my-load-balancer-2')
      expect(my_load_balancer_2_policies).to eq([
        "vpc-cbcbc2a9-my-load-balancer-2-http-80-http-80-LBCookieStickinessPolicyType-XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX",
        "vpc-cbcbc2a9-my-load-balancer-2-https-443-http-80-AppCookieStickinessPolicyType-XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX",
        "vpc-cbcbc2a9-my-load-balancer-2-https-443-http-80-SSLNegotiationPolicyType-XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX",
      ])
    end
  end
end
