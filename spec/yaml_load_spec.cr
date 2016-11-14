require "./spec_helper"

describe YAML::Composer do

  it "load string" do
    example = <<-YAML
    ---
    Hello String
    ...
    YAML

    doc = YAML.load(example)

    doc.should eq("Hello String")
  end

  it "load integer" do
    example = <<-YAML
    ---
    10
    ...
    YAML

    doc = YAML.load(example)

    doc.class.should eq(Int64)
    doc.should eq(10)
  end

  it "load float" do
    example = <<-YAML
    ---
    10.0
    ...
    YAML

    doc = YAML.load(example)

    doc.class.should eq(Float64)
    doc.should eq(10.0)
  end

  it "load null" do
    example = <<-YAML
    ---
    null
    ...
    YAML

    doc = YAML.load(example)

    doc.class.should eq(Nil)
    doc.should eq(nil)
  end

  it "load sequence" do
    example = <<-YAML
    ---
    - foo
    - bar
    ...
    YAML

    doc = YAML.load(example)

    doc.class.should eq(Array(String))
    doc.should eq(["foo", "bar"])
  end

  it "load mapping" do
    example = <<-YAML
    ---
    foo: oof
    bar: rab
    ...
    YAML

    doc = YAML.load(example)

    doc.class.should eq(Hash(String, String))
    doc.should eq({"foo" => "oof", "bar" => "rab"})
  end

end
