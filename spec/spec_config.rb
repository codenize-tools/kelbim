$: << File.expand_path("#{File.dirname __FILE__}/../lib")
$: << File.expand_path("#{File.dirname __FILE__}/../spec")

require 'rubygems'
require 'kelbim'
require 'spec_helper'

unless $__rspec_configure__
  RSpec.configure do |config|
    config.before(:each) do
      elbfile { (<<-EOS)
  ec2 do
  end

  ec2 "vpc-c1cbc2a3" do
  end

  ec2 "vpc-cbcbc2a9" do
  end
          EOS
      }
    end

    config.after(:all) do
      elbfile { (<<-EOS)
  ec2 do
  end

  ec2 "vpc-c1cbc2a3" do
  end

  ec2 "vpc-cbcbc2a9" do
  end
        EOS
      }
    end
  end

  $__rspec_configure__ = true
end
