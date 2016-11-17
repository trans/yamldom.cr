require "./spec_helper"

describe YAML::Composer do

  it "composes nothing" do
    example = <<-YAML
    ---
    ...
    YAML

    doc = YAML.compose(example)

    doc.class.should eq(YAML::Scalar)
    doc.tag.should eq("tag:yaml.org,2002:null")
    doc.value.should eq("")
  end

  it "composes a simple one scalar document" do
    example = <<-YAML
    --- !foo
    Hello String
    ...
    YAML

    doc = YAML.compose(example)

    doc.class.should eq(YAML::Scalar)
    doc.tag.should eq("!foo")
  end

  it "composes a simple one sequence" do
    example = <<-YAML
    --- !bar
    - 1
    - 2
    - 3
    ...
    YAML

    doc = YAML.compose(example)

    doc.class.should eq(YAML::Sequence)
    doc.tag.should eq("!bar")
  end

  it "handles tag declarations" do
    example = <<-YAML
    %TAG !foo! tag:foo.org,2000:
    --- !foo!str
    1 2 3
    ...
    YAML

    doc = YAML.compose(example)

    doc.class.should eq(YAML::Scalar)   
    doc.tag.should eq("tag:foo.org,2000:str")
  end

end
