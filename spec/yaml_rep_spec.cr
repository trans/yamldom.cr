require "./spec_helper"

describe YAML::Representation do

  it "parses a simple one scalar document" do
    example = <<-YAML
    --- !foo
    Hello String
    ...
    YAML

    doc = YAML::Representation.parse(example)
    
    doc.class.should eq(YAML::Representation::Document)
    doc.tag.should eq("!foo")
  end

  it "parses a simple one sequence document" do
    example = <<-YAML
    --- !bar
    - 1
    - 2
    - 3
    ...
    YAML

    doc = YAML::Representation.parse(example)

    doc.class.should eq(YAML::Representation::Document)   
    doc.tag.should eq("!bar")
  end

end
