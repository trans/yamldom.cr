class YAML::Emitter
  protected getter io

  def initialize(@io : IO)
    @emitter = Pointer(Void).malloc(LibYAML::EMITTER_SIZE).as(LibYAML::Emitter*)
    @event = LibYAML::Event.new
    @closed = false
    LibYAML.yaml_emitter_initialize(@emitter)
    LibYAML.yaml_emitter_set_output(@emitter, ->(data, buffer, size) {
      emitter = data.as(YAML::Emitter)
      emitter.io.write(Slice.new(buffer, size))
      1
    }, self.as(Void*))
  end

  def self.new(io : IO)
    emitter = new(io)
    yield emitter ensure emitter.close
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

  def scalar(node : Scalar)
    string = node.to_s
    LibYAML.yaml_scalar_event_initialize(
      pointerof(@event), nil, ctag(node.tag), string, string.bytesize, implicit, implicit, node.style
    )
    yaml_emit("scalar")
    #emit scalar, nil, nil, string, string.bytesize, 1, 1, LibYAML::ScalarStyle::ANY
  end

  def scalar(string)
    emit scalar, nil, nil, string, string.bytesize, 1, 1, LibYAML::ScalarStyle::ANY
  end

  def <<(value)
    scalar value.to_s
  end

  def sequence_start(node : Sequence)
    LibYAML.yaml_sequence_start_event_initialize(pointerof(@event), nil, ctag(node.tag), implicit, node.style)
    yaml_emit("sequence_start")
    #emit sequence_start, nil, nil, 0, LibYAML::SequenceStyle::ANY
  end

  def sequence(node : Sequence)
    sequence_start(node)
    yield
    sequence_end
  end

  def sequence_start
    emit sequence_start, nil, nil, 0, LibYAML::SequenceStyle::ANY
  end

  def sequence_end
    emit sequence_end
  end

  def sequence
    sequence_start
    yield
    sequence_end
  end

  def mapping_start(node : Mapping)
    LibYAML.yaml_mapping_start_event_initialize(pointerof(@event), nil, ctag(node.tag), implicit, node.style)
    yaml_emit("mapping_start")
    #emit mapping_start, nil, nil, 0, LibYAML::MappingStyle::ANY
  end

  def mapping_start
    emit mapping_start, nil, nil, 0, LibYAML::MappingStyle::ANY
  end

  def mapping_end
    emit mapping_end
  end

  def mapping(node : Mapping)
    mapping_start(node)
    yield
    mapping_end
  end

  def mapping
    mapping_start
    yield
    mapping_end
  end

  def flush
    LibYAML.yaml_emitter_flush(@emitter)
  end

  def finalize
    return if @closed
    LibYAML.yaml_emitter_delete(@emitter)
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
    ret = LibYAML.yaml_emitter_emit(@emitter, pointerof(@event))
    if ret != 1
      raise YAML::Error.new("error emitting #{event_name}")
    end
  end

  # Union type `(String | Nil)` of `tag` causes an error.
  # This bit of code works around it.
  private ctag(tag : String?)
    tag.try(&.to_unsafe) || Pointer(UInt8).null
  end
end
