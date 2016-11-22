require "./spec_helper"

describe YAML::Mapping do
  describe "#new" do
    it "can be initialized with no arguments" do
      n = YAML::Mapping.new
      n.size.should eq(0)
      n.tag.should eq("tag:yaml.org,2002:map")
    end
    it "can be initialize with regular hash" do
      n = YAML::Mapping.new({"A"=>1, "B"=>2, "C"=>3})
      n.size.should eq(3)
      n.tag.should eq("tag:yaml.org,2002:map")
      #n.nodes[0].should be_a(YAML::Scalar)
      n.node("A").should be_a(YAML::Scalar)
    end
    it "with custom tag (short)" do
      n = YAML::Mapping.new({"A"=>"X"}, "!foo")
      n.tag.should eq("!foo")
    end
    it "with custom tag (long)" do
      n = YAML::Mapping.new({"B"=>"Y"}, "tag:foo.org,2002:bar")
      n.tag.should eq("tag:foo.org,2002:bar")
    end
    it "from composition" do
      node = YAML.compose("{ A: 1, B: 2, C: 3 }")
      node.should be_a(YAML::Mapping)
    end
  end

  describe "#node" do
    it "allows easy access to underlying nodes" do
      n = YAML::Mapping.new({"A"=>1, "B"=>2, "C"=>3})
      n.node("A").should be_a(YAML::Scalar)
      n.node("A").value.should eq("1")
    end
    it "allows easy access to underlying nodes (composed)" do
      n = YAML.compose("{ A: 1, B: 2, C: 3 }")
      n.node("A").should be_a(YAML::Scalar)
      n.node("A").value.should eq("1")
    end
  end

  describe "#each" do
    it "can iterate over value" do
      n = YAML::Mapping.new({"A"=>1,"B"=>2,"C"=>3})
      i = 0; s = ""
      n.each{ |k,v| i += 1; s += v.as(String) }
      i.should eq(3)
      s.should eq("123")
    end
    it "can iterate over value (composed)" do
      n = YAML.compose("{ A: 1, B: 2, C: 3 }")
      i = 0; s = ""
      n.each{ |k,v| i += 1; s += v.as(String) }
      i.should eq(3)
      s.should eq("123")
    end
  end

  describe "#each_node" do
    it "can iterate over nodes" do
      n = YAML::Mapping.new({"A"=>1,"B"=>2,"C"=>3})
      i = 0
      n.each_node{ |t| i += 1; t.should be_a(Tuple(YAML::Node,YAML::Node)) }
      i.should eq(3)
    end
    it "can iterate over nodes (composed)" do
      n = YAML.compose("{ A: 1, B: 2, C: 3 }")
      i = 0
      n.each_node{ |t| i += 1; t.should be_a(Tuple(YAML::Node,YAML::Node)) }
      i.should eq(3)
    end
  end

  describe "#map" do
    it "can map over its values" do
      n = YAML::Mapping.new({"A"=>1,"B"=>2,"C"=>3})
      a = n.map{ |k,v| k }
      a.size.should eq(3)
      a[0].should be_a(String)
    end
  end

  describe "#==" do
    it "is equal to another scalar with same value and tag (1)" do
      a = YAML::Mapping.new({"A"=>"X"}, "!foo")
      b = YAML::Mapping.new({"A"=>"X"}, "!foo")
      a.should eq(b)
    end
    it "is equal to another scalar with same value and tag (2)" do
      a = YAML::Mapping.new({"A"=>"100"})
      b = YAML::Mapping.new({"A"=>"100"})
      a.should eq(b)
    end
  end

  describe "#hash" do
    it "has the same hash if equal" do
      a = YAML::Mapping.new({"A"=>"100"})
      b = YAML::Mapping.new({"A"=>"100"})
      a.hash.should eq(b.hash)
    end
  end

  describe "#tag" do
    it "can have a blank tag" do
      n = YAML::Mapping.new({"A"=>1,"B"=>2,"C"=>3}, "")
      n.tag.should eq("")
    end
  end

  describe "#canonical_tag" do
    it "will nonethless have the proper canonical tag" do
      n = YAML::Mapping.new({"A"=>1,"B"=>2,"C"=>3}, "")
      n.canonical_tag.should eq("tag:yaml.org,2002:map")
    end
  end

  describe "#value" do
    it "has a value" do
      s = YAML::Mapping.new({"K"=>"V"})
      k = YAML::Scalar.new("K")
      v = YAML::Scalar.new("V")
      s.value.should eq({k=>v})
    end
  end

  describe "#<<" do
    it "can append a node" do
      n = YAML::Mapping.new({"K"=>"V"})
      n << {"X": "Y"}
      n.nodes[-1].value.should eq({"X": "Y"})
    end
  end

  describe "#style" do
    it "has a style" do
      n = YAML::Mapping.new({"K"=>"V"})
      n.style.should eq(LibYAML::MappingStyle::ANY)
    end
    it "can have the style changed" do
      n = YAML::Mapping.new({"K"=>"V"}, "")
      n.style = LibYAML::MappingStyle::FLOW
      n.style.should eq(LibYAML::MappingStyle::FLOW)
    end
  end
end
