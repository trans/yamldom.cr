require "yaml"

require "./yaml_rep/version"
require "./yaml_rep/node"
require "./yaml_rep/scalar"
require "./yaml_rep/sequence"
require "./yaml_rep/mapping"
require "./yaml_rep/kind"
require "./yaml_rep/document"
#require "./yaml_rep/stream"
require "./yaml_rep/parser"


module YAML::Representation

  def self.parse(content : String | IO)
    parser = Parser.new(content)
    parser.parse
  end

  def self.parse_all(content : String | IO)
    parser = Parser.new(content)
    parser.parse_all
  end

end
