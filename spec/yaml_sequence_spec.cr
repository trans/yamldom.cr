require "./spec_helper"

describe YAML::Sequence do
  describe "#new" do
    it "can be initialized with no arguments" do
      n = YAML::Sequence.new
      n.value.size.should eq(0)
      n.tag.should eq("tag:yaml.org,2002:seq")
    end
    it "can be initialize with regular array" do
      n = YAML::Sequence.new(["A", "B", "C"])
      n.size.should eq(3)
      n.tag.should eq("tag:yaml.org,2002:seq")
      n.nodes[0].should be_a(YAML::Scalar)
      n.node(0).should be_a(YAML::Scalar)
    end
    it "creates a custom sequence" do
      it "has correct tag" do
        n = YAML::Sequence.new(["FOO"], "!foo")
        n.tag.should eq("!foo")
        n.nodes[0].value.should eq("FOO")

        n = YAML::Sequence.new(["BAR"], "tag:foo.org,2002:bar")
        n.tag.should eq("tag:foo.org,2002:bar")
      end
    end
  end

  describe "#each" do
    it "can iterate over value" do
      n = YAML::Sequence.new([1,2,3])
      i = 0; s = ""
      n.each{ |x| i += 1; s += x.as(String) }
      i.should eq(3)
      s.should eq("123")
    end
  end

  describe "#each_node" do
    it "can iterate over its nodes" do
      n = YAML::Sequence.new([1,2,3])
      i = 0
      n.each_node{ |n| i += 1; n.should be_a(YAML::Node) }
      i.should eq(3)
    end
  end

  describe "#map" do
    it "can map over its values" do
      n = YAML::Sequence.new([1,2,3])
      a = n.map{ |x| x }
      a.size.should eq(3)
      a[0].should be_a(String)
    end
  end

  describe "#==" do
    it "is equal to another scalar with same value and tag (1)" do
      a = YAML::Sequence.new(["test"], "!foo")
      b = YAML::Sequence.new(["test"], "!foo")
      a.should eq(b)
    end
    it "is equal to another scalar with same value and tag (2)" do
      a = YAML::Sequence.new(["100"])
      b = YAML::Sequence.new(["100"])
      a.should eq(b)
    end
  end

  describe "#hash" do
    it "has the same hash if equal" do
      a = YAML::Sequence.new(["100"])
      b = YAML::Sequence.new(["100"])
      a.hash.should eq(b.hash)
    end
  end

  describe "#tag" do
    it "can have a blank tag" do
      n = YAML::Sequence.new([1,2,3], "")
      n.tag.should eq("")
    end
  end

  describe "#canonical_each" do
    it "will nonethless have the proper canonical tag" do
      n = YAML::Sequence.new([1,2,3], "")
      n.canonical_tag.should eq("tag:yaml.org,2002:seq")
    end
  end

  describe "#value" do
    it "has a value" do
      s = YAML::Sequence.new(["test"])
      a = YAML::Scalar.new("test")
      s.value.should eq([a])
    end
  end

  describe "#<<" do
    it "can merge a node" do
      n = YAML::Sequence.new(["test"])
      n.value << YAML::Scalar.new("append")
      n.nodes[-1].value.should eq("append")
    end
  end

  describe "#style" do
    it "has a style" do
      n = YAML::Sequence.new(["test"])
      n.style.should eq(LibYAML::SequenceStyle::ANY)
    end
    it "can have the style changed" do
      n = YAML::Sequence.new(["test"], "")
      n.style = LibYAML::SequenceStyle::FLOW
      n.style.should eq(LibYAML::SequenceStyle::FLOW)
    end
  end
end
