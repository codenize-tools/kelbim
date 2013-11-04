describe Kelbim::Client do
  it "empty" do
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
