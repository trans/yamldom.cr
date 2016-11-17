require "./spec_helper"

describe YAML do

  it "dump string" do
    yml = YAML.dump("hello")
    yml.should eq("--- hello\n...\n")
  end

  it "dump nil" do
    yml = YAML.dump(nil)
    yml.should eq("--- \n...\n")
  end

  it "dump integer" do
    yml = YAML.dump(10)
    yml.should eq("--- 10\n...\n")
  end

  it "dump float" do
    yml = YAML.dump(2.0)
    yml.should eq("--- 2.0\n...\n")
  end

  it "dump array of string" do
    yml = YAML.dump(["foo","bar"])
    yml.should eq("---\n- foo\n- bar\n")
  end

  it "dump hash of string => string" do
    yml = YAML.dump({"foo"=>"bar"})
    yml.should eq("---\nfoo: bar\n")
  end

  it "dump mixed hash" do
    yml = YAML.dump({"foo"=>"bar", "baz"=>10})
    yml.should eq("---\nfoo: bar\nbaz: 10\n")
  end

end
