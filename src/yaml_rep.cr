require "yaml"

require "./yaml_rep/version"
require "./yaml_rep/node"
require "./yaml_rep/scalar"
require "./yaml_rep/sequence"
require "./yaml_rep/mapping"
require "./yaml_rep/kind"
require "./yaml_rep/document"
#require "./yaml_rep/stream"
require "./yaml_rep/tag"
require "./yaml_rep/tag/register"
require "./yaml_rep/composer"
require "./yaml_rep/serializer"

module YAML

  def self.load(content : String | IO)
    root_node = compose(content)
    serializer = Serializer.new
    serializer.serialize(root_node)
  end

  def self.compose(content : String | IO)
    composer = Composer.new(content)
    composer.compose
  end

  def self.compose_all(content : String | IO)
    composer = Composer.new(content)
    composer.compose_all
  end

end
