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
      listener [:http, 80] => [:http, 80]
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
    end

    health_check do
      target "TCP:80"
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
    end

    health_check do
      target "TCP:8080"
      timeout 10
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
    end

    health_check do
      target "HTTP:80/any.html"
      timeout 5
      interval 30
      healthy_threshold 10
      unhealthy_threshold 10
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
        :policies=>[]}],
     :health_check=>
      {:interval=>30,
       :target=>"TCP:80",
       :healthy_threshold=>10,
       :timeout=>5,
       :unhealthy_threshold=>2},
     :scheme=>"internet-facing",
     :attributes=>{:additional_attributes=>[], :connection_settings=>{:idle_timeout=>60}, :access_log=>{:enabled=>false}, :cross_zone_load_balancing=>{:enabled=>false}, :connection_draining=>{:enabled=>false, :timeout=>300}},
     :dns_name=>"my-load-balancer-NNNNNNNNNN.us-west-1.elb.amazonaws.com",
     :availability_zones=>["us-west-1a", "us-west-1b", "us-west-1c"]}},
 "vpc-c1cbc2a3"=>
  {"my-load-balancer-1"=>
    {:instances=>["i-d8662b13", "i-dd662b16", "i-de662b15", "i-df662b14"],
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
       :timeout=>10,
       :unhealthy_threshold=>2},
     :scheme=>"internet-facing",
     :attributes=>{:additional_attributes=>[], :connection_settings=>{:idle_timeout=>60}, :access_log=>{:enabled=>false}, :cross_zone_load_balancing=>{:enabled=>false}, :connection_draining=>{:enabled=>false, :timeout=>300}},
     :dns_name=>"my-load-balancer-1-NNNNNNNNNN.us-west-1.elb.amazonaws.com",
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
        :policies=>[]}],
     :health_check=>
      {:interval=>30,
       :target=>"HTTP:80/any.html",
       :healthy_threshold=>10,
       :timeout=>5,
       :unhealthy_threshold=>10},
     :scheme=>"internal",
     :attributes=>{:additional_attributes=>[], :connection_settings=>{:idle_timeout=>60}, :access_log=>{:enabled=>false}, :cross_zone_load_balancing=>{:enabled=>false}, :connection_draining=>{:enabled=>false, :timeout=>300}},
     :dns_name=>
      "internal-my-load-balancer-2-NNNNNNNNNN.us-west-1.elb.amazonaws.com",
     :subnets=>["subnet-211c1543", "subnet-487c360e"],
     :security_groups=>["default", "vpc-cbcbc2a9-1", "vpc-cbcbc2a9-2"]}}}
    )
  end
end
