# TODO: Don't think we need separate Emitter class, it's code can be incorporated into Serializer.

# Serializer converts intermediate representation into a serialization of events.
# This class interfaces with LibYAML which takes care of the final leg of createing a
# character stream to produce the final YAML document.
#
class YAML::Serializer

  def initialize(tag_schema : TagSchema = DEFAULT_SCHEMA)
    @tag_schema = tag_schema
  end

  # Serialize intermediate representation.

  # Serialize single document returning a String.
  def serialize(node : Node)
    String.build do |str_io|
      serialize(node, str_io)
    end
  end

  # Serialize single document dumping to IO.
  def serialize(node : Node, io : IO)
    YAML::Emitter.new(io) do |emitter|
      emitter.stream do
        emitter.document do
          serialize_node(node, emitter)
        end
      end
    end
  end

  # Serialize a stream returning a String.
  def serialize(nodes : Array(Node))
    String.build do |str_io|
      serialize(nodes, str_io)
    end
  end

  # Serialize a stream dumping to IO.
  def serialize(nodes : Array(Node), io : IO)
    YAML::Emitter.new(io) do |emitter|
      emitter.stream do
        nodes.each do |node|
          emitter.document do
            serialize_node(node, emitter)
          end
        end
      end
    end
  end

  def serialize(node : YAML::Scalar, emitter : YAML::Emitter)
    emitter.scalar(node.value, node.tag)
  end

  def serialize(node : YAML::Sequence, emitter : Emitter)
    emitter.sequence do
      node.each do |n|
        serialize(n, emitter) 
      end
    end
  end

  def serialize(node : YAML::Mapping, emitter : Emitter)
    emitter.mapping do
      node.each do |k, v|
        serialize(k, emitter)
        serialize(v, emitter)
      end
    end
  end

  # Direct serialization of native data types.

  # Serialize object to a String.
  def serialize(object)
    String.build do |str_io|
      serialize(object, str_io)
    end
  end

  # Serialize object to IO.
  def serialize(object, io : IO)
    YAML::Emitter.new(io) do |emitter|
      emitter.stream do
        emitter.document do
          serialize(object, emitter)
        end
      end
    end
  end

  # Direct serialization of native data types are provided
  # to improve performance, in particualr by reducing memory footprint
  # becausde no intermedaite representation needs to be created.

  # Serialize Nil.
  def serialize(nothing : Nil, emitter : YAML::Emitter)
    emitter.scalar("")
  end

  # Serialize Bool.
  def serialize(bool : Bool, emitter : YAML::Emitter)
    emitter.scalar(bool)
  end

  # Serialize String.
  def serialize(string : String, emitter : YAML::Emitter)
    emitter.scalar(string)
  end

  # Serialize Symbol.
  def serialize(symbol : Symbol, emitter : YAML::Emitter)
    emitter.scalar(symbol)
  end

  # Serialize Number.
  def serialize(number : Number, emitter : YAML::Emitter)
    emitter.scalar(number.to_s)
  end

  # Serialize Array.
  def serialize(array : Array, emitter : YAML::Emitter)
    emitter.sequence do
      array.each{ |e| serialize(e, emitter) }
    end
  end

  # Serialize Hash.
  def serialize(hash : Hash, emitter : YAML::Emitter)
    emitter.mapping do
      hash.each do |key, value|
        serialize(key, emitter)
        serialize(value, emitter)
      end
    end
  end

  # Serialize Tuple.
  def serialize(tuple : Tuple, emitter : YAML::Emitter)
    emitter.sequence do
      tuple.each{ |e| serialize(e, emitter) }
    end
  end

  # Serialize NamedTuple.
  def serialize(named_tuple : NamedTuple, emitter : YAML::Emitter)
    emitter.mapping do
      named_tuple.each do |key, value|
        serialize(key, emitter)
        serialize(value, emitter)
      end
    end
  end

  # Serialize Set.
  def serialize(set : Set, emitter : YAML::Emitter)
    emitter.sequence do
      set.each{ |e| serialize(e, emitter) }
    end
  end

  # Serialize Enum.
  def serialize(enumr : Enum, emitter : YAML::Emitter)
    emitter.scalar(enumr.value)
  end

  # Serialize Time using standard ISO format.
  #
  # TODO: The tag schema should be able to control the format of time.
  #       This means that serialization should probably be defined there too?
  def serialize(time : Time, emitter : YAML::Emitter)
    emitter.scalar(Time::Format::ISO_8601_DATE_TIME.format(time))
  end

  # Serialize any other object. This requires that the object have
  # a `#to_canonical` method, which ultimately reduces to a native
  # data type.
  def serialize(object, emitter : YAML::Emitter)
    serialize(object.to_canonical, emitter)
  end

end
