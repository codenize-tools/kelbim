ENV['IGNORE_RECURSION'] = '1'
require File.expand_path("#{File.dirname(__FILE__)}/../kelbim_spec.rb")

describe Kelbim::Client do
  it do
    updated = elbfile { (<<-EOS)
ec2 do
end

ec2 "vpc-c1cbc2a3" do
end

ec2 "vpc-cbcbc2a9" do
end
      EOS
    }

    expect(updated).to be_false
    exported = export_elb
    expect(exported).to eq({})
  end
end
