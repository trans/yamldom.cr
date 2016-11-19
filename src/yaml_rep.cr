require "yaml"

require "./yaml_rep/node"
require "./yaml_rep/scalar"
require "./yaml_rep/collection"
require "./yaml_rep/sequence"
require "./yaml_rep/mapping"
require "./yaml_rep/pull_parser"
require "./yaml_rep/composer"
#require "./yaml_rep/serializer"

module YAML
  # TODO: Maybe these should be in LibYAML module?
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

  def self.compose(content : String | IO)
    composer = Composer.new(content)
    composer.compose
  end

  def self.compose_stream(content : String | IO)
    composer = Composer.new(content)
    composer.compose_stream
  end

  def self.dump_stream(docs : Array, io : IO)
    String.builder do |str_io|
      dump_stream(docs, str_io)
    end
  end

  def self.dump_stream(docs : Array, io : IO)
    YAML::Emitter.new(io) do |emitter|
      emitter.stream do
        docs.each do |doc|
          emitter.document do
            doc.to_yaml(emitter)
          end
        end
      end
    end
  end

end
