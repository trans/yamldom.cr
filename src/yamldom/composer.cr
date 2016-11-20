# YAML Intermediate Representation Composer uses the pull parser
# to convert parser events into YAML nodes.
class YAML::Composer

  # TODO: Pass parser thru Node.new instead.
  #   Technically it should be possible to compose nodes by passing the
  #   pull parser thru `Node#new` methods, similar to how emitting works.
  #   This would make the Composer class obsolete. To do this though would
  #   also require passing an anchors cache around so anchored node can be
  #   stored and resolved. Might also consider a YAML::Document class to
  #   initiate the process, instead of relying on Node class itself for that.

  def initialize(content : String | IO)
    @pull_parser = YAML::PullParser.new(content)
    @anchors = {} of String => Node #YAML::Type
  end

  def self.new(content)
    composer = new(content)
    yield composer ensure composer.close
  end

  def close
    @pull_parser.close
  end

  def compose_stream
    documents = Array(Node).new
    loop do
      case @pull_parser.read_next
      when EventKind::STREAM_END
        return documents
      when EventKind::DOCUMENT_START
        documents << compose_document
      else
        unexpected_event
      end
    end
    documents
  end

  # Alias for `#compose_stream`.
  def compose_all
    compose_stream
  end

  def compose
    value = (
      case @pull_parser.read_next
      when EventKind::STREAM_END
        YAML::Scalar.new(nil)
      when EventKind::DOCUMENT_START
        compose_document
      else
        unexpected_event
      end
    )
    value.not_nil!
  end

  def compose_document
    @pull_parser.read_next
    value = compose_node
    unless @pull_parser.read_next == EventKind::DOCUMENT_END
      raise "Expected DOCUMENT_END"
    end
    value
  end

  def compose_node
    case @pull_parser.kind
    when EventKind::SCALAR
      anchor compose_scalar, @pull_parser.scalar_anchor
    when EventKind::ALIAS
      @anchors[@pull_parser.alias_anchor]
    when EventKind::SEQUENCE_START
      compose_sequence
    when EventKind::MAPPING_START
      compose_mapping
    else
      unexpected_event
    end
  end

  def compose_scalar
    value = @pull_parser.value
    if value
      if scalar_tag == "" && @pull_parser.value == ""
        YAML::Scalar.new(nil)
      else
        YAML::Scalar.new(value, scalar_tag, scalar_style)
      end
    else
      YAML::Scalar.new(nil)
    end
  end

  def compose_sequence
    sequence = Sequence.new(sequence_tag, sequence_style)
    anchor sequence, @pull_parser.sequence_anchor

    loop do
      case @pull_parser.read_next
      when EventKind::SEQUENCE_END
        return sequence
      else
        sequence << compose_node
      end
    end
    sequence
  end

  def compose_mapping
    mapping = Mapping.new(mapping_tag, mapping_style)
    anchor mapping, @pull_parser.mapping_anchor

    loop do
      case @pull_parser.read_next
      when EventKind::MAPPING_END
        return mapping
      else
        key = compose_node
        tag = key.tag #@pull_parser.tag
        @pull_parser.read_next
        value = compose_node
        if key == "<<" && value.is_a?(Mapping) && tag != "tag:yaml.org,2002:str"
          mapping.merge!(value)
        else
          mapping[key] = value
        end
      end
    end
    mapping
  end

  def anchor(value, anchor)
    @anchors[anchor] = value if anchor
    value
  end

  # TODO: Is tag ever nil? Should we allow it to be so?

  private def scalar_tag
    @pull_parser.scalar_tag || ""
  end

  private def sequence_tag
    @pull_parser.sequence_tag || ""
  end

  private def mapping_tag
    @pull_parser.mapping_tag || ""
  end

  #private def implicit
  #  @pull_parser.implicit
  #end

  private def scalar_style
    @pull_parser.scalar_style
  end

  private def sequence_style
    @pull_parser.sequence_style
  end

  private def mapping_style
    @pull_parser.mapping_style
  end

  private def unexpected_event
    raise "Unexpected event: #{@pull_parser.kind}"
  end

  private def raise(msg)
    ::raise ParseException.new(msg, @pull_parser.problem_line_number, @pull_parser.problem_column_number)
  end

end
