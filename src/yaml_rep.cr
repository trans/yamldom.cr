require "yaml"

require "./yaml_rep/core_ext"
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
require "./yaml_rep/tag_schema/json_schema"
require "./yaml_rep/tag_schema/core_schema"
require "./yaml_rep/tag_schema/config_schema"
#require "./yaml_rep/tag_schema/marshal_schema"
require "./yaml_rep/stream"

module YAML
  module Tags
    STR   = "tag:yaml.org,2002:str"
    SEQ   = "tag:yaml.org,2002:seq"
    MAP   = "tag:yaml.org,2002:map"
    NULL  = "tag:yaml.org,2002:null"
    INT   = "tag:yaml.org,2002:int"
    BOOL  = "tag:yaml.org,2002:bool"
    FLOAT = "tag:yaml.org,2002:float"

    #IMPLICIT = {SEQ, MAP, STR, NULL, BOOL, INT, FLOAT}
  end

  DEFAULT_SCHEMA = CoreSchema.new

  # TODO: cache stream by schema ?

  def self.load(content : (String | IO), tag_schema : TagSchema = DEFAULT_SCHEMA)
    stream = Stream.new(tag_schema)
    stream.load(content)
  end

  def self.load_stream(content : (String | IO), tag_schema : TagSchema = DEFAULT_SCHEMA)
    stream = Stream.new(tag_schema)
    stream.load_stream(content)

    #roots = compose_stream(content)
    #roots.map{ |root| constructor.construct(root) }
  end

  def self.compose(content : (String | IO), tag_schema : TagSchema = DEFAULT_SCHEMA)
    stream = Stream.new(tag_schema)
    stream.compose(content)
    #composer = Composer.new(content)
    #composer.compose
  end

  def self.compose_stream(content : (String | IO), tag_schema : TagSchema = DEFAULT_SCHEMA)
    stream = Stream.new(tag_schema)
    stream.compose_stream(content)

    #composer = Composer.new(content)
    #composer.compose_stream
  end

  def self.dump(data, tag_schema : TagSchema = DEFAULT_SCHEMA)
    stream = Stream.new(tag_schema)
    stream.dump(data) 
  end

end
