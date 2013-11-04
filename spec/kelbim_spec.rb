$: << File.expand_path("#{File.dirname __FILE__}/../lib")
$: << File.expand_path("#{File.dirname __FILE__}/../spec")

require 'rubygems'
require 'kelbim'
require 'spec_helper'

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

unless ENV['IGNORE_RECURSION']
  Dir.glob("#{File.dirname(__FILE__)}/specs/*.rb").each do |fn|
    require fn
  end
end
