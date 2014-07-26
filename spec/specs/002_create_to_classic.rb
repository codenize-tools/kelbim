require File.expand_path("#{File.dirname __FILE__}/../spec_config")

describe Kelbim::Client do
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
      EOS
    }

    expect(updated).to be_true
    exported = export_elb
    expect(export_elb).to eq(
{nil=>
  {"my-load-balancer"=>
    {:instances=>["i-cd1c8a91", "i-e01086bc", "i-e11086bd", "i-e21086be"],
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
     :attributes=>{:connection_settings=>{:idle_timeout=>60}, :access_log=>{:enabled=>false}, :cross_zone_load_balancing=>{:enabled=>false}, :connection_draining=>{:enabled=>false, :timeout=>300}},
     :dns_name=>"my-load-balancer-NNNNNNNNNN.us-west-1.elb.amazonaws.com",
     :availability_zones=>["us-west-1a", "us-west-1b", "us-west-1c"]}}}
    )
  end
end
