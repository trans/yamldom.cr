module YAML

  ##
  # YAML Intermediate Representation Composer.
  #
  class Composer
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
      documents = [] of Document
      loop do
        case @pull_parser.read_next
        when EventKind::STREAM_END
          return documents
        when EventKind::DOCUMENT_START
          documents << Document.new(compose_document)
        else
          unexpected_event
        end
      end
    end

    def compose_all
      compose_stream
    end

    def compose
      value = case @pull_parser.read_next
              when EventKind::STREAM_END
                Scalar.new(tag, nil)  #nil
              when EventKind::DOCUMENT_START
                compose_document
              else
                unexpected_event
              end
      #YAML::Any.new(value)
      value.not_nil!
    end

    def compose_document
      @pull_parser.read_next
      value = compose_node
      unless @pull_parser.read_next == EventKind::DOCUMENT_END
        raise "Expected DOCUMENT_END"
      end
      # TODO: Should we bother with document?
      value #Document.new(value)
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
      Scalar.new(tag, @pull_parser.value)
    end

    def compose_sequence
      sequence = Sequence.new(tag)
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
      mapping = Mapping.new(tag)
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

    def tag
      @pull_parser.tag || ""
    end

    private def unexpected_event
      raise "Unexpected event: #{@pull_parser.kind}"
    end

    private def raise(msg)
      ::raise ParseException.new(msg, @pull_parser.problem_line_number, @pull_parser.problem_column_number)
    end
  end

end
