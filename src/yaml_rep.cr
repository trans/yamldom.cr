require "yaml"

require "./yaml_rep/version"
require "./yaml_rep/node"
require "./yaml_rep/scalar"
require "./yaml_rep/sequence"
require "./yaml_rep/mapping"
#require "./yaml_rep/kind"
#require "./yaml_rep/tag"
require "./yaml_rep/composer"
require "./yaml_rep/serializer"
require "./yaml_rep/tag_schema"
require "./yaml_rep/stream"

module YAML

  # TODO: cache stream by schema 

  def self.load(content : (String | IO), tag_schema : TagSchema = CoreSchema.new)
    stream = Stream.new(tag_schema)
    stream.load(content)
  end

  def self.load_stream(content : (String | IO), tag_schema : TagSchema = CoreSchema.new)
    stream = Stream.new(tag_schema)
    stream.load_stream(content)

    #roots = compose_stream(content)
    #roots.map{ |root| constructor.construct(root) }
  end

  def self.compose(content : (String | IO), tag_schema : TagSchema = CoreSchema.new)
    stream = Stream.new(tag_schema)
    stream.compose(content)
    #composer = Composer.new(content)
    #composer.compose
  end

  def self.compose_stream(content : (String | IO), tag_schema : TagSchema = CoreSchema.new)
    stream = Stream.new(tag_schema)
    stream.compose_stream(content)

    #composer = Composer.new(content)
    #composer.compose_stream
  end

end
