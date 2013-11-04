# Kelbim

Kelbim is a tool to manage ELB.

It defines the state of ELB using DSL, and updates ELB according to DSL.

[![Build Status](https://drone.io/bitbucket.org/winebarrel/kelbim/status.png)](https://drone.io/bitbucket.org/winebarrel/kelbim/latest)


**Attention! This is a alpha version!**

## Installation

Add this line to your application's Gemfile:

    gem 'kelbim'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install kelbim

## Usage

```sh
export AWS_ACCESS_KEY_ID='...'
export AWS_SECRET_ACCESS_KEY='...'
export AWS_REGION='ap-northeast-1'
kelbim -e -o ELBfile  # export EKB
vi ELB
kelbim -a --dry-run
kelbim -a             # apply `ELBfile` to ELB
```

## ELBfile example

```ruby
require 'other/elbfile'

# EC2 Classic
ec2 do
  load_balancer "my-load-balancer" do
    instances(
      "cthulhu",
      "nyar",
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
      "ap-northeast-1a",
      "ap-northeast-1b"
    )
  end
end

# EC2 VPC
ec2 "vpc-XXXXXXXXX" do
  load_balancer "my-load-balancer", :internal => true do
    instances(
      "nyar",
      "yog"
    )

    listeners do
      listener [:tcp, 80] => [:tcp, 80]
      listener [:https, 443] => [:http, 80] do
        app_cookie_stickiness "CookieName"=>"20"
        ssl_negotiation ["Protocol-TLSv1", "Protocol-SSLv3", "AES256-SHA", ...]
        server_certificate "my-cert"
      end
    end

    health_check do
      target "TCP:80"
      timeout 5
      interval 30
      healthy_threshold 10
      unhealthy_threshold 2
    end

    subnets(
      "subnet-XXXXXXXX"
    )

    security_groups(
      "default"
    )
  end
end
```

## Test

```ruby
ec2 "vpc-XXXXXXXXX" do
  load_balancer "my-load-balancer" do
    spec do
      host = "my-load-balancer-XXXXXXXXXX.ap-northeast-1.elb.amazonaws.com"

      expect {
        timeout(3) do
          socket = TCPSocket.open(host, 8080)
          socket.close if socket
        end
      }.not_to raise_error
    end
    ...
```

```sh
shell> kelbim -t
Test `ELBfile`
...

Finished in 3.16 seconds
3 examples, 0 failures
```

## Link
* [RubyGems.org site](http://rubygems.org/gems/kelbim)
