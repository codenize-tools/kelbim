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
    updated = elbfile { (<<-EOS)
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
    {:instances=>["i-8281bc40", "i-8381bc41", "i-8481bc46", "i-8581bc47"],
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
        :policies=>
         [{:name=>"ELBSecurityPolicy-2015-05",
           :type=>"SSLNegotiationPolicyType",
           :attributes=>
            {"Reference-Security-Policy"=>["ELBSecurityPolicy-2015-05"],
             "Protocol-SSLv2"=>["false"],
             "Protocol-TLSv1"=>["true"],
             "Protocol-SSLv3"=>["false"],
             "Protocol-TLSv1.1"=>["true"],
             "Protocol-TLSv1.2"=>["true"],
             "Server-Defined-Cipher-Order"=>["true"],
             "ECDHE-ECDSA-AES128-GCM-SHA256"=>["true"],
             "ECDHE-RSA-AES128-GCM-SHA256"=>["true"],
             "ECDHE-ECDSA-AES128-SHA256"=>["true"],
             "ECDHE-RSA-AES128-SHA256"=>["true"],
             "ECDHE-ECDSA-AES128-SHA"=>["true"],
             "ECDHE-RSA-AES128-SHA"=>["true"],
             "DHE-RSA-AES128-SHA"=>["false"],
             "ECDHE-ECDSA-AES256-GCM-SHA384"=>["true"],
             "ECDHE-RSA-AES256-GCM-SHA384"=>["true"],
             "ECDHE-ECDSA-AES256-SHA384"=>["true"],
             "ECDHE-RSA-AES256-SHA384"=>["true"],
             "ECDHE-RSA-AES256-SHA"=>["true"],
             "ECDHE-ECDSA-AES256-SHA"=>["true"],
             "AES128-GCM-SHA256"=>["true"],
             "AES128-SHA256"=>["true"],
             "AES128-SHA"=>["true"],
             "AES256-GCM-SHA384"=>["true"],
             "AES256-SHA256"=>["true"],
             "AES256-SHA"=>["true"],
             "DHE-DSS-AES128-SHA"=>["false"],
             "CAMELLIA128-SHA"=>["false"],
             "EDH-RSA-DES-CBC3-SHA"=>["false"],
             "DES-CBC3-SHA"=>["true"],
             "ECDHE-RSA-RC4-SHA"=>["false"],
             "RC4-SHA"=>["false"],
             "ECDHE-ECDSA-RC4-SHA"=>["false"],
             "DHE-DSS-AES256-GCM-SHA384"=>["false"],
             "DHE-RSA-AES256-GCM-SHA384"=>["false"],
             "DHE-RSA-AES256-SHA256"=>["false"],
             "DHE-DSS-AES256-SHA256"=>["false"],
             "DHE-RSA-AES256-SHA"=>["false"],
             "DHE-DSS-AES256-SHA"=>["false"],
             "DHE-RSA-CAMELLIA256-SHA"=>["false"],
             "DHE-DSS-CAMELLIA256-SHA"=>["false"],
             "CAMELLIA256-SHA"=>["false"],
             "EDH-DSS-DES-CBC3-SHA"=>["false"],
             "DHE-DSS-AES128-GCM-SHA256"=>["false"],
             "DHE-RSA-AES128-GCM-SHA256"=>["false"],
             "DHE-RSA-AES128-SHA256"=>["false"],
             "DHE-DSS-AES128-SHA256"=>["false"],
             "DHE-RSA-CAMELLIA128-SHA"=>["false"],
             "DHE-DSS-CAMELLIA128-SHA"=>["false"],
             "ADH-AES128-GCM-SHA256"=>["false"],
             "ADH-AES128-SHA"=>["false"],
             "ADH-AES128-SHA256"=>["false"],
             "ADH-AES256-GCM-SHA384"=>["false"],
             "ADH-AES256-SHA"=>["false"],
             "ADH-AES256-SHA256"=>["false"],
             "ADH-CAMELLIA128-SHA"=>["false"],
             "ADH-CAMELLIA256-SHA"=>["false"],
             "ADH-DES-CBC3-SHA"=>["false"],
             "ADH-DES-CBC-SHA"=>["false"],
             "ADH-RC4-MD5"=>["false"],
             "ADH-SEED-SHA"=>["false"],
             "DES-CBC-SHA"=>["false"],
             "DHE-DSS-SEED-SHA"=>["false"],
             "DHE-RSA-SEED-SHA"=>["false"],
             "EDH-DSS-DES-CBC-SHA"=>["false"],
             "EDH-RSA-DES-CBC-SHA"=>["false"],
             "IDEA-CBC-SHA"=>["false"],
             "RC4-MD5"=>["false"],
             "SEED-SHA"=>["false"],
             "DES-CBC3-MD5"=>["false"],
             "DES-CBC-MD5"=>["false"],
             "RC2-CBC-MD5"=>["false"],
             "PSK-AES256-CBC-SHA"=>["false"],
             "PSK-3DES-EDE-CBC-SHA"=>["false"],
             "KRB5-DES-CBC3-SHA"=>["false"],
             "KRB5-DES-CBC3-MD5"=>["false"],
             "PSK-AES128-CBC-SHA"=>["false"],
             "PSK-RC4-SHA"=>["false"],
             "KRB5-RC4-SHA"=>["false"],
             "KRB5-RC4-MD5"=>["false"],
             "KRB5-DES-CBC-SHA"=>["false"],
             "KRB5-DES-CBC-MD5"=>["false"],
             "EXP-EDH-RSA-DES-CBC-SHA"=>["false"],
             "EXP-EDH-DSS-DES-CBC-SHA"=>["false"],
             "EXP-ADH-DES-CBC-SHA"=>["false"],
             "EXP-DES-CBC-SHA"=>["false"],
             "EXP-RC2-CBC-MD5"=>["false"],
             "EXP-KRB5-RC2-CBC-SHA"=>["false"],
             "EXP-KRB5-DES-CBC-SHA"=>["false"],
             "EXP-KRB5-RC2-CBC-MD5"=>["false"],
             "EXP-KRB5-DES-CBC-MD5"=>["false"],
             "EXP-ADH-RC4-MD5"=>["false"],
             "EXP-RC4-MD5"=>["false"],
             "EXP-KRB5-RC4-SHA"=>["false"],
             "EXP-KRB5-RC4-MD5"=>["false"]}}]}],
     :health_check=>
      {:unhealthy_threshold=>2,
       :interval=>30,
       :healthy_threshold=>10,
       :timeout=>5,
       :target=>"HTTP:80/index.html"},
     :scheme=>"internet-facing",
     :dns_name=>"my-load-balancer-NNNNNNNNNN.us-west-1.elb.amazonaws.com",
     :attributes=>
      {:additional_attributes=>[],
       :connection_settings=>{:idle_timeout=>60},
       :cross_zone_load_balancing=>{:enabled=>false},
       :access_log=>{:enabled=>false},
       :connection_draining=>{:enabled=>false, :timeout=>300}},
     :availability_zones=>["us-west-1a", "us-west-1b", "us-west-1c"]}},
 "vpc-c1cbc2a3"=>
  {"my-load-balancer-1"=>
    {:instances=>["i-d8662b13", "i-dd662b16", "i-de662b15", "i-df662b14"],
     :listeners=>
      [{:protocol=>:https,
        :port=>443,
        :instance_protocol=>:http,
        :instance_port=>80,
        :server_certificate=>"test2",
        :policies=>
         [{:name=>"ELBSecurityPolicy-2015-05",
           :type=>"SSLNegotiationPolicyType",
           :attributes=>
            {"Reference-Security-Policy"=>["ELBSecurityPolicy-2015-05"],
             "Protocol-SSLv2"=>["false"],
             "Protocol-TLSv1"=>["true"],
             "Protocol-SSLv3"=>["false"],
             "Protocol-TLSv1.1"=>["true"],
             "Protocol-TLSv1.2"=>["true"],
             "Server-Defined-Cipher-Order"=>["true"],
             "ECDHE-ECDSA-AES128-GCM-SHA256"=>["true"],
             "ECDHE-RSA-AES128-GCM-SHA256"=>["true"],
             "ECDHE-ECDSA-AES128-SHA256"=>["true"],
             "ECDHE-RSA-AES128-SHA256"=>["true"],
             "ECDHE-ECDSA-AES128-SHA"=>["true"],
             "ECDHE-RSA-AES128-SHA"=>["true"],
             "DHE-RSA-AES128-SHA"=>["false"],
             "ECDHE-ECDSA-AES256-GCM-SHA384"=>["true"],
             "ECDHE-RSA-AES256-GCM-SHA384"=>["true"],
             "ECDHE-ECDSA-AES256-SHA384"=>["true"],
             "ECDHE-RSA-AES256-SHA384"=>["true"],
             "ECDHE-RSA-AES256-SHA"=>["true"],
             "ECDHE-ECDSA-AES256-SHA"=>["true"],
             "AES128-GCM-SHA256"=>["true"],
             "AES128-SHA256"=>["true"],
             "AES128-SHA"=>["true"],
             "AES256-GCM-SHA384"=>["true"],
             "AES256-SHA256"=>["true"],
             "AES256-SHA"=>["true"],
             "DHE-DSS-AES128-SHA"=>["false"],
             "CAMELLIA128-SHA"=>["false"],
             "EDH-RSA-DES-CBC3-SHA"=>["false"],
             "DES-CBC3-SHA"=>["true"],
             "ECDHE-RSA-RC4-SHA"=>["false"],
             "RC4-SHA"=>["false"],
             "ECDHE-ECDSA-RC4-SHA"=>["false"],
             "DHE-DSS-AES256-GCM-SHA384"=>["false"],
             "DHE-RSA-AES256-GCM-SHA384"=>["false"],
             "DHE-RSA-AES256-SHA256"=>["false"],
             "DHE-DSS-AES256-SHA256"=>["false"],
             "DHE-RSA-AES256-SHA"=>["false"],
             "DHE-DSS-AES256-SHA"=>["false"],
             "DHE-RSA-CAMELLIA256-SHA"=>["false"],
             "DHE-DSS-CAMELLIA256-SHA"=>["false"],
             "CAMELLIA256-SHA"=>["false"],
             "EDH-DSS-DES-CBC3-SHA"=>["false"],
             "DHE-DSS-AES128-GCM-SHA256"=>["false"],
             "DHE-RSA-AES128-GCM-SHA256"=>["false"],
             "DHE-RSA-AES128-SHA256"=>["false"],
             "DHE-DSS-AES128-SHA256"=>["false"],
             "DHE-RSA-CAMELLIA128-SHA"=>["false"],
             "DHE-DSS-CAMELLIA128-SHA"=>["false"],
             "ADH-AES128-GCM-SHA256"=>["false"],
             "ADH-AES128-SHA"=>["false"],
             "ADH-AES128-SHA256"=>["false"],
             "ADH-AES256-GCM-SHA384"=>["false"],
             "ADH-AES256-SHA"=>["false"],
             "ADH-AES256-SHA256"=>["false"],
             "ADH-CAMELLIA128-SHA"=>["false"],
             "ADH-CAMELLIA256-SHA"=>["false"],
             "ADH-DES-CBC3-SHA"=>["false"],
             "ADH-DES-CBC-SHA"=>["false"],
             "ADH-RC4-MD5"=>["false"],
             "ADH-SEED-SHA"=>["false"],
             "DES-CBC-SHA"=>["false"],
             "DHE-DSS-SEED-SHA"=>["false"],
             "DHE-RSA-SEED-SHA"=>["false"],
             "EDH-DSS-DES-CBC-SHA"=>["false"],
             "EDH-RSA-DES-CBC-SHA"=>["false"],
             "IDEA-CBC-SHA"=>["false"],
             "RC4-MD5"=>["false"],
             "SEED-SHA"=>["false"],
             "DES-CBC3-MD5"=>["false"],
             "DES-CBC-MD5"=>["false"],
             "RC2-CBC-MD5"=>["false"],
             "PSK-AES256-CBC-SHA"=>["false"],
             "PSK-3DES-EDE-CBC-SHA"=>["false"],
             "KRB5-DES-CBC3-SHA"=>["false"],
             "KRB5-DES-CBC3-MD5"=>["false"],
             "PSK-AES128-CBC-SHA"=>["false"],
             "PSK-RC4-SHA"=>["false"],
             "KRB5-RC4-SHA"=>["false"],
             "KRB5-RC4-MD5"=>["false"],
             "KRB5-DES-CBC-SHA"=>["false"],
             "KRB5-DES-CBC-MD5"=>["false"],
             "EXP-EDH-RSA-DES-CBC-SHA"=>["false"],
             "EXP-EDH-DSS-DES-CBC-SHA"=>["false"],
             "EXP-ADH-DES-CBC-SHA"=>["false"],
             "EXP-DES-CBC-SHA"=>["false"],
             "EXP-RC2-CBC-MD5"=>["false"],
             "EXP-KRB5-RC2-CBC-SHA"=>["false"],
             "EXP-KRB5-DES-CBC-SHA"=>["false"],
             "EXP-KRB5-RC2-CBC-MD5"=>["false"],
             "EXP-KRB5-DES-CBC-MD5"=>["false"],
             "EXP-ADH-RC4-MD5"=>["false"],
             "EXP-RC4-MD5"=>["false"],
             "EXP-KRB5-RC4-SHA"=>["false"],
             "EXP-KRB5-RC4-MD5"=>["false"]}}]},
       {:protocol=>:tcp,
        :port=>8080,
        :instance_protocol=>:tcp,
        :instance_port=>8080,
        :server_certificate=>nil,
        :policies=>[]}],
     :health_check=>
      {:unhealthy_threshold=>2,
       :interval=>30,
       :healthy_threshold=>10,
       :timeout=>5,
       :target=>"TCP:8080"},
     :scheme=>"internet-facing",
     :dns_name=>"my-load-balancer-1-NNNNNNNNNN.us-west-1.elb.amazonaws.com",
     :attributes=>
      {:additional_attributes=>[],
       :connection_settings=>{:idle_timeout=>60},
       :cross_zone_load_balancing=>{:enabled=>false},
       :access_log=>{:enabled=>false},
       :connection_draining=>{:enabled=>false, :timeout=>300}},
     :subnets=>["subnet-567c3610", "subnet-5e1c153c"],
     :security_groups=>["default", "vpc-c1cbc2a3-1", "vpc-c1cbc2a3-2"]}},
 "vpc-cbcbc2a9"=>
  {"my-load-balancer-2"=>
    {:instances=>["i-086429c3", "i-096429c2", "i-0a6429c1", "i-0b6429c0"],
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
        :policies=>
         [{:name=>"ELBSecurityPolicy-2015-05",
           :type=>"SSLNegotiationPolicyType",
           :attributes=>
            {"Reference-Security-Policy"=>["ELBSecurityPolicy-2015-05"],
             "Protocol-SSLv2"=>["false"],
             "Protocol-TLSv1"=>["true"],
             "Protocol-SSLv3"=>["false"],
             "Protocol-TLSv1.1"=>["true"],
             "Protocol-TLSv1.2"=>["true"],
             "Server-Defined-Cipher-Order"=>["true"],
             "ECDHE-ECDSA-AES128-GCM-SHA256"=>["true"],
             "ECDHE-RSA-AES128-GCM-SHA256"=>["true"],
             "ECDHE-ECDSA-AES128-SHA256"=>["true"],
             "ECDHE-RSA-AES128-SHA256"=>["true"],
             "ECDHE-ECDSA-AES128-SHA"=>["true"],
             "ECDHE-RSA-AES128-SHA"=>["true"],
             "DHE-RSA-AES128-SHA"=>["false"],
             "ECDHE-ECDSA-AES256-GCM-SHA384"=>["true"],
             "ECDHE-RSA-AES256-GCM-SHA384"=>["true"],
             "ECDHE-ECDSA-AES256-SHA384"=>["true"],
             "ECDHE-RSA-AES256-SHA384"=>["true"],
             "ECDHE-RSA-AES256-SHA"=>["true"],
             "ECDHE-ECDSA-AES256-SHA"=>["true"],
             "AES128-GCM-SHA256"=>["true"],
             "AES128-SHA256"=>["true"],
             "AES128-SHA"=>["true"],
             "AES256-GCM-SHA384"=>["true"],
             "AES256-SHA256"=>["true"],
             "AES256-SHA"=>["true"],
             "DHE-DSS-AES128-SHA"=>["false"],
             "CAMELLIA128-SHA"=>["false"],
             "EDH-RSA-DES-CBC3-SHA"=>["false"],
             "DES-CBC3-SHA"=>["true"],
             "ECDHE-RSA-RC4-SHA"=>["false"],
             "RC4-SHA"=>["false"],
             "ECDHE-ECDSA-RC4-SHA"=>["false"],
             "DHE-DSS-AES256-GCM-SHA384"=>["false"],
             "DHE-RSA-AES256-GCM-SHA384"=>["false"],
             "DHE-RSA-AES256-SHA256"=>["false"],
             "DHE-DSS-AES256-SHA256"=>["false"],
             "DHE-RSA-AES256-SHA"=>["false"],
             "DHE-DSS-AES256-SHA"=>["false"],
             "DHE-RSA-CAMELLIA256-SHA"=>["false"],
             "DHE-DSS-CAMELLIA256-SHA"=>["false"],
             "CAMELLIA256-SHA"=>["false"],
             "EDH-DSS-DES-CBC3-SHA"=>["false"],
             "DHE-DSS-AES128-GCM-SHA256"=>["false"],
             "DHE-RSA-AES128-GCM-SHA256"=>["false"],
             "DHE-RSA-AES128-SHA256"=>["false"],
             "DHE-DSS-AES128-SHA256"=>["false"],
             "DHE-RSA-CAMELLIA128-SHA"=>["false"],
             "DHE-DSS-CAMELLIA128-SHA"=>["false"],
             "ADH-AES128-GCM-SHA256"=>["false"],
             "ADH-AES128-SHA"=>["false"],
             "ADH-AES128-SHA256"=>["false"],
             "ADH-AES256-GCM-SHA384"=>["false"],
             "ADH-AES256-SHA"=>["false"],
             "ADH-AES256-SHA256"=>["false"],
             "ADH-CAMELLIA128-SHA"=>["false"],
             "ADH-CAMELLIA256-SHA"=>["false"],
             "ADH-DES-CBC3-SHA"=>["false"],
             "ADH-DES-CBC-SHA"=>["false"],
             "ADH-RC4-MD5"=>["false"],
             "ADH-SEED-SHA"=>["false"],
             "DES-CBC-SHA"=>["false"],
             "DHE-DSS-SEED-SHA"=>["false"],
             "DHE-RSA-SEED-SHA"=>["false"],
             "EDH-DSS-DES-CBC-SHA"=>["false"],
             "EDH-RSA-DES-CBC-SHA"=>["false"],
             "IDEA-CBC-SHA"=>["false"],
             "RC4-MD5"=>["false"],
             "SEED-SHA"=>["false"],
             "DES-CBC3-MD5"=>["false"],
             "DES-CBC-MD5"=>["false"],
             "RC2-CBC-MD5"=>["false"],
             "PSK-AES256-CBC-SHA"=>["false"],
             "PSK-3DES-EDE-CBC-SHA"=>["false"],
             "KRB5-DES-CBC3-SHA"=>["false"],
             "KRB5-DES-CBC3-MD5"=>["false"],
             "PSK-AES128-CBC-SHA"=>["false"],
             "PSK-RC4-SHA"=>["false"],
             "KRB5-RC4-SHA"=>["false"],
             "KRB5-RC4-MD5"=>["false"],
             "KRB5-DES-CBC-SHA"=>["false"],
             "KRB5-DES-CBC-MD5"=>["false"],
             "EXP-EDH-RSA-DES-CBC-SHA"=>["false"],
             "EXP-EDH-DSS-DES-CBC-SHA"=>["false"],
             "EXP-ADH-DES-CBC-SHA"=>["false"],
             "EXP-DES-CBC-SHA"=>["false"],
             "EXP-RC2-CBC-MD5"=>["false"],
             "EXP-KRB5-RC2-CBC-SHA"=>["false"],
             "EXP-KRB5-DES-CBC-SHA"=>["false"],
             "EXP-KRB5-RC2-CBC-MD5"=>["false"],
             "EXP-KRB5-DES-CBC-MD5"=>["false"],
             "EXP-ADH-RC4-MD5"=>["false"],
             "EXP-RC4-MD5"=>["false"],
             "EXP-KRB5-RC4-SHA"=>["false"],
             "EXP-KRB5-RC4-MD5"=>["false"]}}]}],
     :health_check=>
      {:unhealthy_threshold=>2,
       :interval=>30,
       :healthy_threshold=>10,
       :timeout=>5,
       :target=>"HTTP:80/index.html"},
     :scheme=>"internal",
     :dns_name=>
      "internal-my-load-balancer-2-NNNNNNNNNN.us-west-1.elb.amazonaws.com",
     :attributes=>
      {:additional_attributes=>[],
       :connection_settings=>{:idle_timeout=>60},
       :cross_zone_load_balancing=>{:enabled=>false},
       :connection_draining=>{:timeout=>300, :enabled=>false},
       :access_log=>{:enabled=>false}},
     :subnets=>["subnet-211c1543", "subnet-487c360e"],
     :security_groups=>["default", "vpc-cbcbc2a9-1", "vpc-cbcbc2a9-2"]}}}
    )

    with_elb do |elb|
      my_load_balancer_policies = get_policy_names(elb, 'my-load-balancer')
      expect(my_load_balancer_policies).to eq([nil])

      my_load_balancer_1_policies = get_policy_names(elb, 'my-load-balancer-1')
      expect(my_load_balancer_1_policies).to eq([nil])

      # XXX:
      #my_load_balancer_2_policies = get_policy_names(elb, 'my-load-balancer-2')
      #expect(my_load_balancer_2_policies).to eq([nil])
    end
  end
end
