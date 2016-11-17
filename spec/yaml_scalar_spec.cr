require "./spec_helper"

describe YAML::Scalar do

  it "handles simple nil" do
    n = YAML::Scalar.new(nil)
    n.tag.should eq("tag:yaml.org,2002:null")
    n.value.should eq("")
  end

end
