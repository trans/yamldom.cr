# Base class for tag schemas.
#
abstract class YAML::TagSchema

  alias Type = Nil | String | Array(Type) | Hash(Type, Type)

  def as_type(value)
    value.as(Type)
  end

  # Fallback is just original string value or nil.
  def construct(node : YAML::Scalar)
    case node.tag
    when Tags::NULL
      nil
    else
      node.value
    end
  end

  # Construct sequence with array.
  def construct(node : YAML::Sequence)
    node.map{ |n| as_type(construct(n)) }.type_reduce
  end

  # Construct mapping using hash.
  def construct(node : YAML::Mapping)
    keys = node.map{ |k,v| as_type(construct(k)) }
    vals = node.map{ |k,v| as_type(construct(v)) }
    Hash.zip(keys, vals)
  end

  # Represent `nil`.
  def represent(value : Nil, tag : String = Tags::NULL)
    #YAML::Null.new("null", Tags::NULL)
    YAML::Scalar.new(nil, tag)
  end

  def represent(value : String, tag : String = Tags::STR)
    YAML::Scalar.new(value, tag)
  end

  def represent(value : Array, tag : String = Tags::SEQ)
    seq = YAML::Sequence.new(tag)
    value.each do |v|
      seq << represent(v)
    end
    seq
  end

  def represent(value : Hash, tag : String? = Tags::MAP)
    map = YAML::Mapping.new(tag)
    value.each do |k, v|
      map[represent(k)] = represent(v)
    end
    map
  end

  def represent(value : Tuple, tag : String = Tags::SEQ)
    seq = YAML::Sequence.new(tag)
    value.each do |v|
      seq << represent(v)
    end
    seq
  end

  def represent(value : NamedTuple, tag : String? = Tags::MAP)
    map = YAML::Mapping.new(tag)
    value.each do |k, v|
      map[represent(k)] = represent(v)
    end
    map
  end

  # Handle all other types of objects.
  def represent(value, tag : String)
    represent(value.to_canonical, tag)
  end


  # Shortcut for serialization driect from native data to 
  # serializer.
  def serialize(value : String, tag : String? = Tags::STR)

  end

  #def self.load(content : String | IO)
  #  constructor = new
  #  constructor.construct(compose(content))
  #end

  #def load(content : String | IO)
  #  compose(content).map{ |root| construct(root) }
  #end

  #
  #def construct(node : YAML::Null)
  #  nil
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
