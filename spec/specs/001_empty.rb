describe Kelbim::Client do
  it "empty" do
    exported = export_elb
    expect(exported).to eq({})
  end
end
