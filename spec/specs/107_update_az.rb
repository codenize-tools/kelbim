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

    availability_zones(
      "us-west-1c"
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
      target "HTTP:80/index.html"
      timeout 5
      interval 30
      healthy_threshold 10
      unhealthy_threshold 2
    end

    availability_zones(
      "us-west-1a"
    )
  end

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
        :policies=>[]}],
     :health_check=>
      {:interval=>30,
       :target=>"HTTP:80/index.html",
       :healthy_threshold=>10,
       :timeout=>5,
       :unhealthy_threshold=>2},
     :scheme=>"internet-facing",
     :dns_name=>"my-load-balancer-NNNNNNNNNN.us-west-1.elb.amazonaws.com",
     :availability_zones=>["us-west-1a"]},
   "my-load-balancer-2"=>
    {:instances=>["i-5cf2c707", "i-5df2c706", "i-6097f23a", "i-6197f23b"],
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
     :dns_name=>"my-load-balancer-2-NNNNNNNNNN.us-west-1.elb.amazonaws.com",
     :availability_zones=>["us-west-1a", "us-west-1b", "us-west-1c"]}}}
    )
  end
end
