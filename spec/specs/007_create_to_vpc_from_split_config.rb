require File.expand_path("#{File.dirname __FILE__}/../spec_config")

describe Kelbim::Client do
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

ec2 "vpc-c1cbc2a3" do
  load_balancer "my-load-balancer-2" do
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
      EOS
    }

    expect(updated).to be_true
    exported = export_elb
    expect(exported).to eq(
{"vpc-c1cbc2a3"=>
  {"my-load-balancer-1"=>
    {:instances=>["i-d8662b13", "i-dd662b16", "i-de662b15", "i-df662b14"],
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
     :scheme=>"internet-facing",
     :attributes=>{:additional_attributes=>[], :connection_settings=>{:idle_timeout=>60}, :access_log=>{:enabled=>false}, :cross_zone_load_balancing=>{:enabled=>false}, :connection_draining=>{:enabled=>false, :timeout=>300}},
     :dns_name=>"my-load-balancer-1-NNNNNNNNNN.us-west-1.elb.amazonaws.com",
     :subnets=>["subnet-567c3610", "subnet-5e1c153c"],
     :security_groups=>["default", "vpc-c1cbc2a3-1", "vpc-c1cbc2a3-2"]},
   "my-load-balancer-2"=>
    {:instances=>["i-d8662b13", "i-dd662b16", "i-de662b15", "i-df662b14"],
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
     :scheme=>"internet-facing",
     :attributes=>{:additional_attributes=>[], :connection_settings=>{:idle_timeout=>60}, :access_log=>{:enabled=>false}, :cross_zone_load_balancing=>{:enabled=>false}, :connection_draining=>{:enabled=>false, :timeout=>300}},
     :dns_name=>"my-load-balancer-2-NNNNNNNNNN.us-west-1.elb.amazonaws.com",
     :subnets=>["subnet-567c3610", "subnet-5e1c153c"],
     :security_groups=>["default", "vpc-c1cbc2a3-1", "vpc-c1cbc2a3-2"]}}}
    )
  end
end
