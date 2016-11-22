require "./spec_helper"

describe YAML::Scalar do
  describe "#new" do
    it "creates a string scalar" do
      n = YAML::Scalar.new("HELLO")
      n.tag.should eq("tag:yaml.org,2002:str")
      n.value.should eq("HELLO")
    end
    it "creatges int scalar" do
      n = YAML::Scalar.new(100)
      n.tag.should eq("tag:yaml.org,2002:int")
      n.value.should eq("100")
    end
    it "creates a float scalar" do
      n = YAML::Scalar.new(4.35)
      n.tag.should eq("tag:yaml.org,2002:float")
      n.value.should eq("4.35")
    end
    it "crates a true bool scalar" do
      n = YAML::Scalar.new(true)
      n.tag.should eq("tag:yaml.org,2002:bool")
      n.value.should eq("true")
    end
    it "creates a false bool scalar" do
      n = YAML::Scalar.new(false)
      n.tag.should eq("tag:yaml.org,2002:bool")
      n.value.should eq("false")
    end
    it "creates a null scalar" do
      n = YAML::Scalar.new(nil)
      n.tag.should eq("tag:yaml.org,2002:null")
      n.value.should eq("")
    end
    it "creates a custom scalar (short tag)" do
      n = YAML::Scalar.new("FOO", "!foo")
      n.tag.should eq("!foo")
      n.value.should eq("FOO")
    end
    it "creates a custom scalar (long tag)" do
      n = YAML::Scalar.new("BAR", "tag:foo.org,2002:bar")
      n.tag.should eq("tag:foo.org,2002:bar")
    end
  end

  describe "#each" do
    it "can iterate over its value" do
      n = YAML::Scalar.new(2)
      i = 0; s = ""
      n.each{ |x| i += 1; s += x }
      i.should eq(1)
      s.should eq("2")
    end
  end

  describe "#each_node" do
    it "can iterate over its node" do
      n = YAML::Scalar.new(2)
      i = 0
      n.each_node{ |n| i += 1; n.should be_a(YAML::Node) }
      i.should eq(1)
    end
  end

  describe "#map" do
    it "can map over its value" do
      n = YAML::Scalar.new(2)
      a = n.map{ |x| x }
      a.size.should eq(1)
      a[0].should be_a(String)
    end
  end

  describe "#==" do
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
  end

  describe "#hash" do
    it "has the same hash if equal" do
      a = YAML::Scalar.new("100", YAML::Tags::INT)
      b = YAML::Scalar.new(100)
      a.hash.should eq(b.hash)
    end
  end

  describe "#tag" do
    it "can have a blank tag" do
      n = YAML::Scalar.new("test", "")
      n.tag.should eq("")
    end
  end

  describe "#canoncial_tag" do
    it "will nonethless have the proper canonical tag" do
      n = YAML::Scalar.new("test", "")
      n.canonical_tag.should eq("tag:yaml.org,2002:str")
    end
  end

  describe "#value" do
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

  describe "#style" do
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
