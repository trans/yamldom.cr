require "./spec_helper"

describe YAML::Scalar do
  describe "string scalar" do
    it "has correct tag" do
      n = YAML::Scalar.new("HELLO")
      n.tag.should eq("tag:yaml.org,2002:str")
    end
    it "has correct value" do
      n = YAML::Scalar.new("HELLO")
      n.value.should eq("HELLO")
    end
  end
  describe "int scalar" do
    it "has correct tag" do
      n = YAML::Scalar.new(100)
      n.tag.should eq("tag:yaml.org,2002:int")
    end
    it "has correct value" do
      n = YAML::Scalar.new(100)
      n.value.should eq("100")
    end
  end
  describe "float scalar" do
    it "has correct tag" do
      n = YAML::Scalar.new(4.35)
      n.tag.should eq("tag:yaml.org,2002:float")
    end
    it "has correct value" do
      n = YAML::Scalar.new(4.35)
      n.value.should eq("4.35")
    end
  end
  describe "bool scalar" do
    it "has correct tag when true" do
      n = YAML::Scalar.new(true)
      n.tag.should eq("tag:yaml.org,2002:bool")
    end
    it "has correct tag when false" do
      n = YAML::Scalar.new(false)
      n.tag.should eq("tag:yaml.org,2002:bool")
    end
    it "has correct value when true" do
      n = YAML::Scalar.new(true)
      n.value.should eq("true")
    end
    it "has correct value when false" do
      n = YAML::Scalar.new(false)
      n.value.should eq("false")
    end
  end
  describe "null scalar" do
    it "has correct tag" do
      n = YAML::Scalar.new(nil)
      n.tag.should eq("tag:yaml.org,2002:null")
    end
    it "has correct value" do
      n = YAML::Scalar.new(nil)
      n.value.should eq("")
    end
  end
  describe "custom scalar" do
    it "has correct tag" do
      n = YAML::Scalar.new("FOO", "!foo")
      n.tag.should eq("!foo")
      n = YAML::Scalar.new("BAR", "tag:foo.org,2002:bar")
      n.tag.should eq("tag:foo.org,2002:bar")
    end
    it "has correct value" do
      n = YAML::Scalar.new("FOO", "!foo")
      n.value.should eq("FOO")
    end
  end

  describe "enumerablity" do
    it "can iterate over its value" do
      n = YAML::Scalar.new(2)
      i = 0; s = ""
      n.each{ |x| i += 1; s += x }
      i.should eq(1)
      s.should eq("2")
    end
    it "can iterate over its node" do
      n = YAML::Scalar.new(2)
      i = 0
      n.each_node{ |n| i += 1; n.should be_a(YAML::Node) }
      i.should eq(1)
    end
    it "can map over its value" do
      n = YAML::Scalar.new(2)
      i = 0; j = 0
      a = n.map{ |x| x }
      a.size.should eq(1)
      a[0].should be_a(String)
    end
  end

  describe "equality" do
    it "is equal to another scalar with same value and tag (1)" do
      a = YAML::Scalar.new("test", "!foo")
      b = YAML::Scalar.new("test", "!foo")
      a.should eq(b)
    end
    it "is equal to another scalar with same value and tag (2)" do
      a = YAML::Scalar.new("100", YAML::Tags::INT)
      b = YAML::Scalar.new(100)
      a.should eq(b)
    end
    it "has the same hash if equal" do
      a = YAML::Scalar.new("100", YAML::Tags::INT)
      b = YAML::Scalar.new(100)
      a.hash.should eq(b.hash)
    end
  end

  describe "tag" do
    it "can have a blank tag" do
      n = YAML::Scalar.new("test", "")
      n.tag.should eq("")
    end
    it "will nonethless have the proper canonical tag" do
      n = YAML::Scalar.new("test", "")
      n.canonical_tag.should eq("tag:yaml.org,2002:str")
    end
  end

  describe "value" do
    it "has a value" do
      n = YAML::Scalar.new("test", "")
      n.value.should eq("test")
    end
    it "can have the value changed" do
      n = YAML::Scalar.new("test", "")
      n.value = "change"
      n.value.should eq("change")
    end
  end

  describe "style" do
    it "has a style" do
      n = YAML::Scalar.new("test", "")
      n.style.should eq(LibYAML::ScalarStyle::ANY)
    end
    it "can have the style changed" do
      n = YAML::Scalar.new("test", "")
      n.style = LibYAML::ScalarStyle::FOLDED
      n.style.should eq(LibYAML::ScalarStyle::FOLDED)
    end
  end
end
