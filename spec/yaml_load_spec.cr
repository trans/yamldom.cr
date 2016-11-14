require "./spec_helper"

describe YAML::Composer do

  it "serializes string scalar" do
    example = <<-YAML
    ---
    Hello String
    ...
    YAML

    doc = YAML.load(example)

    doc.should eq("Hello String")
  end

  it "serializes integer" do
    example = <<-YAML
    ---
    10
    ...
    YAML

    doc = YAML.load(example)

    doc.class.should eq(Int32)
    doc.should eq(10)
  end

end
