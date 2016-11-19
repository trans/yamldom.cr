require "./spec_helper"

describe YAML do

  it "load string" do
    example = <<-YAML
    ---
    Hello String
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

  it "load null from empty document" do
    example = <<-YAML
    ---
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

    doc.should eq(["foo", "bar"])

    pending "if we can ever reduce the generic type" do
      doc.class.should eq(Array(String))
    end
  end

  it "load mapping" do
    example = <<-YAML
    ---
    foo: oof
    bar: rab
    ...
    YAML

    doc = YAML.load(example)

    doc.should eq({"foo" => "oof", "bar" => "rab"})

    pending "if we can ever reduce the generic type" do
      doc.class.should eq(Hash(String, String))
    end
  end

  it "handles a complex case" do
    example = <<-YAML
    ---
    x:
    - [1, 2, 3]
    - {a: b, c: d}
    y:
      string taht is on 
      multiple lines
    z:
    - 1
    - "2"
    - true
    ...
    YAML
  end

end
