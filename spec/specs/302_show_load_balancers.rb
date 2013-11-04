require File.expand_path("#{File.dirname __FILE__}/../spec_config")

describe Kelbim::Client do
  before do
    elbfile { (<<-EOS)
ec2 do
  load_balancer "my-load-balancer" do
    spec do
      expect(1).to eq(1)
    end

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
    spec do
      expect(1).to eq(1)
    end

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
    spec do
      expect(1).to eq(1)
    end

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
    load_balancers = elbfile(:mode => :show_load_balancers) { '' }

    load_balancers.each do |vpc, elbs|
      elbs.each do |name, dns_name|
        dns_name.sub!(
          /\d+\.us-west-1\.elb\.amazonaws\.com/,
          'NNNNNNNNNN.us-west-1.elb.amazonaws.com')
      end
    end

    expect(load_balancers).to eq(
{"classic"=>
  {"my-load-balancer"=>
    "my-load-balancer-NNNNNNNNNN.us-west-1.elb.amazonaws.com"},
 "vpc-c1cbc2a3"=>
  {"my-load-balancer-1"=>
    "my-load-balancer-1-NNNNNNNNNN.us-west-1.elb.amazonaws.com"},
 "vpc-cbcbc2a9"=>
  {"my-load-balancer-2"=>
    "internal-my-load-balancer-2-NNNNNNNNNN.us-west-1.elb.amazonaws.com"}}
    )
  end
end
