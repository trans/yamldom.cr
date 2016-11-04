module YAML::Representation

	##
	#
	class Parser
		def initialize(content : String | IO)
		  @pull_parser = YAML::PullParser.new(content)
		  @anchors = {} of String => Node #YAML::Type
		end

		def self.new(content)
		  parser = new(content)
		  yield parser ensure parser.close
		end

		def close
		  @pull_parser.close
		end

		def parse_all
		  documents = [] of Document
		  loop do
		    case @pull_parser.read_next
		    when EventKind::STREAM_END
		      return documents
		    when EventKind::DOCUMENT_START
		      documents << Document.new(parse_document)
		    else
		      unexpected_event
		    end
		  end
		end

		def parse
		  value = case @pull_parser.read_next
		          when EventKind::STREAM_END
		            nil
		          when EventKind::DOCUMENT_START
		            parse_document
		          else
		            unexpected_event
		          end
		  #YAML::Any.new(value)
		  value.not_nil!
		end

		def parse_document
		  @pull_parser.read_next
		  value = parse_node
		  unless @pull_parser.read_next == EventKind::DOCUMENT_END
		    raise "Expected DOCUMENT_END"
		  end
      # TODO: Should we bother with document?
		  Document.new(value)
		end

		def parse_node
		  case @pull_parser.kind
		  when EventKind::SCALAR
		    anchor parse_scalar, @pull_parser.scalar_anchor
		  when EventKind::ALIAS
		    @anchors[@pull_parser.alias_anchor]
		  when EventKind::SEQUENCE_START
		    parse_sequence
		  when EventKind::MAPPING_START
		    parse_mapping
		  else
		    unexpected_event
		  end
		end

		def parse_scalar
		  Scalar.new(@pull_parser.tag, @pull_parser.value)
		end

		def parse_sequence
		  sequence = Sequence.new(@pull_parser.tag)
		  anchor sequence, @pull_parser.sequence_anchor

		  loop do
		    case @pull_parser.read_next
		    when EventKind::SEQUENCE_END
		      return sequence
		    else
		      sequence << parse_node
		    end
		  end
		end

		def parse_mapping
		  mapping = Mapping.new(@pull_parser.tag)
		  anchor mapping, @pull_parser.mapping_anchor

		  loop do
		    case @pull_parser.read_next
		    when EventKind::MAPPING_END
		      return mapping
		    else
		      key = parse_node
		      tag = key.tag #@pull_parser.tag
		      @pull_parser.read_next
		      value = parse_node
		      if key == "<<" && value.is_a?(Mapping) && tag != "tag:yaml.org,2002:str"
		        mapping.merge!(value)
		      else
		        mapping[key] = value
		      end
		    end
		  end
		end

		def anchor(value, anchor)
		  @anchors[anchor] = value if anchor
		  value
		end

		private def unexpected_event
		  raise "Unexpected event: #{@pull_parser.kind}"
		end

		private def raise(msg)
		  ::raise ParseException.new(msg, @pull_parser.problem_line_number, @pull_parser.problem_column_number)
		end
	end

end
