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
end

# TagSchema serves as the base class for all other tag schemas.
# In YAML sepcification it is the *Failsafe* schema. It only
# recognizes scalars, sequences and mappings, converting them
# to String, Array and Hash, respectively.
#
#    ------------- CRYSTAL ------------------- | -------- LibYAML --------------
#
#    Native <-- construct --.
#       |                   |
#       '-- represent --> Representation <-- compose --.
#                            |                         |
#                            '-- serialize --> Serialization <-- parse --.
#                                                    |                   |
#                                                    '-- present --> Presentation
#
#
class YAML::TagSchema

  #alias Type = String | Array(Type) | Hash(Type, Type)
  #def as_type(value)
  #  value.as(Type)
  #end

  # Tag methods are used to look the schema tag for a given object.

  def tag(object : String)     ; Tags::STR ; end
  def tag(object : Array)      ; Tags::SEQ ; end
  def tag(object : Tuple)      ; Tags::SEQ ; end
  def tag(object : Hash)       ; Tags::MAP ; end
  def tag(object : NamedTuple) ; Tags::MAP ; end

  # Tag for anything else is as a String.
  def tag(object)
    tag(object.to_s)
  end

  # The type method is the opposite of the tag method.
  # It returns the class that will be cinstructed for a given tag.
  def type(tag : String)
    case tag
    when Tags::STR
      String
    when Tags::SEQ
      Array
    when Tags::MAP
      Hash
    else
     String
    end
  end

  # Construction methods convert intermediate representations into
  # native data types.

  # Construct scalar.
  def construct(node : YAML::Scalar)
    type(node.tag).from_canonical(node.value)
  end

  # Construct scalar.
  #def construct(node : YAML::Scalar)
    #if node.value == ""
    #  nil
    #else
  #    node.value
    #end
  #end

  # Construct sequence with array.
  def construct(node : YAML::Sequence)
    array = [] of typeof(construct(node))
    node.each do |n|
      array << n
    end
    array #.type_reduce
  end

  # Construct mapping using hash.
  def construct(node : YAML::Mapping)
    hash = {} of typeof(construct(node)) => typeof(construct(node))
    node.each do |k, v|
      hash[construct(k)] = construct(v)
    end
    hash
  end

  # Representation methods convert native data types to intermediate
  # representations. This is the opposite of `#construct`.

  # Intermedaite representation of String.
  def represent(value : String, tag : String = Tags::STR)
    YAML::Scalar.new(value, tag) #.type_reduce
  end

  # Intermedaite representation of Array.
  def represent(value : Array, tag : String = Tags::SEQ)
    seq = YAML::Sequence.new(tag)
    value.each do |v|
      seq << represent(v)
    end
    seq
  end

  # Intermedaite representation of Hash.
  def represent(value : Hash, tag : String = Tags::MAP)
    map = YAML::Mapping.new(tag)
    value.each do |k, v|
      map[represent(k)] = represent(v)
    end
    map
  end

  # Intermedaite representation of Tuple.
  def represent(value : Tuple, tag : String = Tags::SEQ)
    seq = YAML::Sequence.new(tag)
    value.each do |v|
      seq << represent(v)
    end
    seq
  end

  # Intermedaite representation of NamedTuple.
  def represent(value : NamedTuple, tag : String = Tags::MAP)
    map = YAML::Mapping.new(tag)
    value.each do |k, v|
      map[represent(k)] = represent(v)
    end
    map
  end

  #def represent(value : Nil, tag : String? = Tags::STR)
  #  YAML::Scalar.new("", tag)
  #end


  # Intermediate representation for all other types of objects.
  # For an object to to be representable it must support the
  # `#to_canonical` method.
  #
  # TODO: Think about this, what if not something that can be represented as a string?
  def represent(object, tag : String = Tags::STR)
    represent(object.to_canonical.to_s, tag)
  end

  # These serialization methods convert intermediate representation
  # into YAML.

  # Serialize single document returning a String.
  def serialize(node : Node)
    String.build do |str_io|
      serialize(node, str_io)
    end
  end

  # Serialize single document dumping to IO.
  def serialize(node : Node, io : IO)
    YAML::Serializer.new(io) do |serializer|
      serializer.stream do
        serializer.document do
          serialize_node(node, serializer)
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
    YAML::Serializer.new(io) do |serializer|
      serializer.stream do
        nodes.each do |node|
          serializer.document do
            serialize_node(node, serializer)
          end
        end
      end
    end
  end

  # Serialize Scalar.
  def serialize(node : YAML::Scalar, serializer : YAML::Serializer)
    serializer.scalar(node.value, node.tag)
  end

  # Serialize Sequence.
  def serialize(node : YAML::Sequence, serializer : YAML::Serializer)
    serializer.sequence do
      node.each do |n|
        serialize(n, serializer) 
      end
    end
  end

  # Serialize Mapping.
  def serialize(node : YAML::Mapping, serializer : YAML::Serializer)
    serializer.mapping do
      node.each do |k, v|
        serialize(k, serializer)
        serialize(v, serializer)
      end
    end
  end

  # For efficiency these methods serialize canonical data types directly,
  # without use of an intermediate representation. This improves performace
  # and memory footprint.

  # Serialize object to a String.
  def serialize(object)
    String.build do |str_io|
      serialize(object, str_io)
    end
  end

  # Serialize object to IO.
  def serialize(object, io : IO)
    YAML::Serializer.new(io) do |serializer|
      serializer.stream do
        serializer.document do
          serialize(object, serializer)
        end
      end
    end
  end

  # Direct serialization of native data types are provided
  # to improve performance, in particualr by reducing memory footprint
  # becausde no intermedaite representation needs to be created.

  # Serialize String.
  def serialize(string : String, serializer : YAML::Serializer)
    serializer.scalar(string, tag(string))
  end

  # Symbols are serialized as strings and cannot round trip.
  def serialize(symbol : Symbol, emitter : YAML::Serializer)
    emitter.scalar(symbol)
  end

  # Serialize Array.
  def serialize(array : Array, serializer : YAML::Serializer)
    serializer.sequence do
      array.each{ |e| serialize(e, serializer) }
    end
  end

  # Serialize Hash.
  def serialize(hash : Hash, serializer : YAML::Serializer)
    serializer.mapping do
      hash.each do |key, value|
        serialize(key, serializer)
        serialize(value, serializer)
      end
    end
  end

  # Serialize Tuple.
  def serialize(tuple : Tuple, serializer : YAML::Serializer)
    serializer.sequence do
      tuple.each{ |e| serialize(e, serializer) }
    end
  end

  # Serialize NamedTuple.
  def serialize(named_tuple : NamedTuple, serializer : YAML::Serializer)
    serializer.mapping do
      named_tuple.each do |key, value|
        serialize(key, serializer)
        serialize(value, serializer)
      end
    end
  end

  # Serialize Set.
  def serialize(set : Set, serializer : YAML::Serializer)
    serializer.sequence do
      set.each{ |e| serialize(e, serializer) }
    end
  end

  # Serialize Enum.
  def serialize(enumr : Enum, serializer : YAML::Serializer)
    serializer.scalar(enumr.value)
  end

  # Serializing any other type of object requires that the object
  # have a `#to_canonical` method, which must ultimately reduce to
  # a native (canonical) data type.
  def serialize(object, serializer : YAML::Serializer)
    serialize(represent(object), serializer)
  end



  #def load(content : String | IO)
  #  constructor = new
  #  constructor.construct(compose(content))
  #end

  #def load(content : String | IO)
  #  compose(content).map{ |root| construct(root) }
  #end


  # Define tag/class associations.
  #
  #    class MyStrean < YAML::Stream
  #      tags("!foo": Foo, "!bar": Bar)
  #    end
  #
  # Note, at this time this can only be used once. Using it again
  # will simply overwrite the prior usage.
    #  macro tags(**tag_to_class)
    #    def tag_class(tag)
    #      case tag
    #      {% for name, class_name in tag_to_class %}
    #      when {{name.stringify}}
    #        {{class_name.id}}
    #      {% end %}
    #      else
    #        nil # ???        
    #      end
    #    end #}
    #  end

end
