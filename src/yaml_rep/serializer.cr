require "yaml/lib_yaml"

module YAML
  #module Tags
  #  STR   = "tag:yaml.org,2002:str"
  #  SEQ   = "tag:yaml.org,2002:seq"
  #  MAP   = "tag:yaml.org,2002:map"
  #  NULL  = "tag:yaml.org,2002:null"
  #  INT   = "tag:yaml.org,2002:int"
  #  BOOL  = "tag:yaml.org,2002:bool"
  #  FLOAT = "tag:yaml.org,2002:float"
  #
  #  #IMPLICIT = {SEQ, MAP, STR, NULL, BOOL, INT, FLOAT}
  #end
end

# Serializer converts intermediate representation into a serialization of events.
# This class interfaces with LibYAML which takes care of the final leg of createing a
# character stream to produce the final YAML document.
#
class YAML::Serializer
  protected getter io

  def initialize(@io : IO)
    @serializer = Pointer(Void).malloc(LibYAML::EMITTER_SIZE).as(LibYAML::Emitter*)
    @event = LibYAML::Event.new
    @closed = false
    LibYAML.yaml_emitter_initialize(@serializer)
    LibYAML.yaml_emitter_set_output(@serializer, ->(data, buffer, size) {
      serializer = data.as(YAML::Serializer)
      serializer.io.write(Slice.new(buffer, size))
      1
    }, self.as(Void*))
  end

  def self.new(io : IO)
    serializer = new(io)
    yield serializer ensure serializer.close
  end

  def stream_start
    emit stream_start, LibYAML::Encoding::UTF8
  end

  def stream_end
    emit stream_end
  end

  def stream
    stream_start
    yield
    stream_end
  end

  def document_start
    emit document_start, nil, nil, nil, 0
  end

  def document_end
    emit document_end, 1
  end

  def document
    document_start
    yield
    document_end
  end

  def scalar(string, tag : String? = nil, style : LibYAML::ScalarStyle = LibYAML::ScalarStyle::ANY)
    #emit scalar, nil, tag, string, string.bytesize, implicit, implicit, LibYAML::ScalarStyle::ANY
    implicit = tag ? (implicit?(tag) ? 1 : 0) : 1
    # Union type `(String | Nil)` of `tag` causes an error. This bit of ugly code works around that.
    utag = tag.try(&.to_unsafe) || Pointer(UInt8).null
    LibYAML.yaml_scalar_event_initialize(
      pointerof(@event), nil, utag, string, string.bytesize, implicit, implicit, style
    )
    yaml_emit("scalar")
  end

  def <<(value)
    scalar value.to_s
  end

  def sequence_start(tag : String? = nil, style : LibYAML::SequenceStyle = LibYAML::SequenceStyle::ANY)
    #emit sequence_start, nil, tag, 0, LibYAML::SequenceStyle::ANY
    implicit = tag ? (implicit?(tag) ? 1 : 0) : 1
    utag = tag.try(&.to_unsafe) || Pointer(UInt8).null
    LibYAML.yaml_sequence_start_event_initialize(pointerof(@event), nil, utag, implicit, style)
    yaml_emit("sequence_start")
  end

  def sequence_end
    emit sequence_end
  end

  def sequence(tag : String? = nil, style : LibYAML::SequenceStyle = LibYAML::SequenceStyle::ANY)
    sequence_start(tag, style)
    yield
    sequence_end
  end

  def mapping_start(tag : String? = nil, style : LibYAML::MappingStyle = LibYAML::MappingStyle::ANY)
    #emit mapping_start, nil, tag, 0, style
    implicit = tag ? (implicit?(tag) ? 1 : 0) : 1
    utag = tag.try(&.to_unsafe) || Pointer(UInt8).null
    LibYAML.yaml_mapping_start_event_initialize(pointerof(@event), nil, utag, implicit, style)
    yaml_emit("mapping_start")
  end

  def mapping_end
    emit mapping_end
  end

  def mapping(tag : String? = nil, style : LibYAML::MappingStyle = LibYAML::MappingStyle::ANY)
    mapping_start(tag, style)
    yield
    mapping_end
  end

  def flush
    LibYAML.yaml_emitter_flush(@serializer)
  end

  def finalize
    return if @closed
    LibYAML.yaml_emitter_delete(@serializer)
  end

  def close
    finalize
    @closed = true
  end

  macro emit(event_name, *args)
    LibYAML.yaml_{{event_name}}_event_initialize(pointerof(@event), {{*args}})
    yaml_emit({{event_name.stringify}})
  end

  private def yaml_emit(event_name)
    ret = LibYAML.yaml_emitter_emit(@serializer, pointerof(@event))
    if ret != 1
      raise YAML::Error.new("error emitting #{event_name}")
    end
  end

  # Determine if a tag can be implicit. All the core YAML types can be.
  def implicit?(tag : String)
    case tag
    #when *IMPLICIT
    when Tags::SEQ, Tags::MAP, Tags::STR, Tags::FLOAT, Tags::INT, Tags::NULL, Tags::BOOL
      true
    else
      false
    end
  end

end
