require File.expand_path("#{File.dirname __FILE__}/../spec_config")

describe Kelbim::Client do
  before do
    elbfile { (<<-EOS)
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
    end

    health_check do
      target "TCP:8080"
      timeout 5
      interval 30
      healthy_threshold 10
      unhealthy_threshold 2
    end

    subnets(
      "subnet-567c3610",
    )

    security_groups(
      "default",
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
    end

    health_check do
      target "TCP:8080"
      timeout 5
      interval 30
      healthy_threshold 10
      unhealthy_threshold 2
    end

    subnets(
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
    )
  end
end
      EOS
    }

    expect(updated).to be_true
    exported = export_elb
    expect(exported).to eq(
{"vpc-c1cbc2a3"=>
  {"my-load-balancer-1"=>
    {:instances=>["i-1e68fe42", "i-1f68fe43", "i-5f3c7000", "i-9d236fc2"],
     :listeners=>
      [{:protocol=>:tcp,
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
     :attributes=>{:access_log=>{:enabled=>false}, :cross_zone_load_balancing=>{:enabled=>false}},
     :dns_name=>"my-load-balancer-1-NNNNNNNNNN.us-west-1.elb.amazonaws.com",
     :subnets=>["subnet-567c3610"],
     :security_groups=>["default", "vpc-c1cbc2a3-1", "vpc-c1cbc2a3-2"]}},
 "vpc-cbcbc2a9"=>
  {"my-load-balancer-2"=>
    {:instances=>["i-113d714e", "i-123d714d", "i-4869ff14", "i-4969ff15"],
     :listeners=>
      [{:protocol=>:http,
        :port=>80,
        :instance_protocol=>:http,
        :instance_port=>80,
        :server_certificate=>nil,
        :policies=>[]}],
     :health_check=>
      {:interval=>30,
       :target=>"HTTP:80/index.html",
       :healthy_threshold=>10,
       :timeout=>5,
       :unhealthy_threshold=>2},
     :scheme=>"internal",
     :attributes=>{:access_log=>{:enabled=>false}, :cross_zone_load_balancing=>{:enabled=>false}},
     :dns_name=>
      "internal-my-load-balancer-2-NNNNNNNNNN.us-west-1.elb.amazonaws.com",
     :subnets=>["subnet-211c1543", "subnet-487c360e"],
     :security_groups=>["default", "vpc-cbcbc2a9-1"]}}}
    )
  end
end
