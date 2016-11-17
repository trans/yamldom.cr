require "./spec_helper"

describe YAML::Composer do

  it "composes nothing" do
    example = <<-YAML
    ---
    ...
    YAML

    doc = YAML.compose(example)

    doc.class.should eq(YAML::Scalar)
    doc.value.should eq("")
    doc.tag.should eq("tag:yaml.org,2002:null")
  end

end
