# Standard YAML Core Schema. This schema handles all the data types specified by
# the YAML 1.2 core standard. Similar to JSONSchema but recognizes some additional
# implict values such as +/-Infinity and NAN.
#
class YAML::CoreSchema < YAML::TagSchema

  #alias CoreType = Nil | Bool | Int64 | Float64 | String | Array(CoreType) | Hash(CoreType, CoreType)
  #def as_type(value)
  #  value.as(CoreType)
  #end

  # Tag methods are used to look the schema tag for a given object.

  def tag(object : String) ; Tags::STR   ; end
  def tag(object : Int)    ; Tags::INT   ; end
  def tag(object : Float)  ; Tags::FLOAT ; end
  def tag(object : Bool)   ; Tags::BOOL  ; end
  def tag(object : Nil)    ; Tags::NULL  ; end
  def tag(object : SYMBOL) ; Tags::STR   ; end

  # The type method is the opposite of the tag method.
  # It returns the class that will be constructed for a given tag.
  def type(tag : String)
    case tag
    when Tags::STR
      String
    when Tags::SEQ
      Array
    when Tags::MAP
      Hash
    when Tags::INT
      Int64
    when Tags::FLOAT
      Float64
    when Tags::BOOL
      Bool
    when Tags::NULL
      Nil
    else
      Nil #implict_type(tag)
    end
  end

  # Construct scalar.
  def construct(node : YAML::Scalar)
    type(node.tag).from_canonical(node.value)
  end

  # Construction methods convert intermediate representations
  # to native data types.

  # Construct Scalar.
  def construct(node : YAML::Scalar)
    case node.tag
    when Tags::STR
      node.value
    when Tags::INT
      construct_integer(node)
    when Tags::FLOAT
      construct_float(node)
    when Tags::BOOL
      construct_bool(node)
    when Tags::NULL
      nil
    else
      construct_implicit(node)
    end
  end

  # Construct implicit scalar.
  def construct_implicit(node : YAML::Scalar)
    case value = node.value
    when /^[-+]?[0-9]+$/
      value.to_i64
    when /^0o[0-7]+$/        # Base 8
      value.to_i64(8)
    when /^0x[0-9a-fA-F]+$/  # Base 16
      value.to_i64(16)
    when /^[-+]?(\.[0-9]+|[0-9]+(\.[0-9]*)?)([eE][-+]?[0-9]+)?$/
      value.to_f64
    when /^[+]?\.inf$/i
      Float64::INFINITY
    when /^[-]\.inf$/i
      -Float64::INFINITY
    when /^\.nan$/i
      Float64::NAN
    when /^true$/i
      true
    when /^false$/i
      false
    when "", "~", /^null$/i
      nil
    else
      value
    end
  end

  # Construct integer.
  def construct_integer(node : YAML::Scalar)
    case value = node.value
    when /^[-+]?[0-9]+$/
      value.to_i64
    when /^0o[0-7]+$/          # Base 8
      value.to_i64(8)
    when /^0x[0-9a-fA-F]+$/    # Base 16
      value.to_i64(16)
    else
      raise YAML::Error.new("invalid integer scalar")
    end
  end

  # Construct float.
  def construct_float(node : YAML::Scalar)
    case value = node.value
    when /^[-+]?(\.[0-9]+|[0-9]+(\.[0-9]*)?)([eE][-+]?[0-9]+)?$/
      value.to_f64
    when /^[+]?\.inf$/i
      Float64::INFINITY
    when /^[-]\.inf$/i
      -Float64::INFINITY
    when /^\.nan$/i
      Float64::NAN
    else
      raise YAML::Error.new("invalid float scalar")
    end
  end

  # Construct boolean.
  def construct_bool(node : YAML::Scalar)
    case node.value
    when /^true$/i
      true
    when /^false$/i
      false
    else
      raise YAML::Error.new("invalid boolean scalar")
    end
  end

  # Representation methods convert native data types to
  # intermediate representations.

  # Intermediate representation of string.
  def represent(value : String, tag : String = Tags::STR)
    YAML::Scalar.new(value, tag)
  end

  # Intermediate representation of integer.
  def represent(value : Int)
    YAML::Scalar.new(value.to_s, Tags::INT)
  end

  # Intermediate representation of float.
  def represent(value : Float)
    if value == Float32::INFINITY
      YAML::Scalar.new(".INF", Tags::FLOAT)
    elsif value == -Float32::INFINITY
      YAML::Scalar.new("-.INF", Tags::FLOAT)
    else
      YAML::Scalar.new(value.to_s, Tags::FLOAT)
    end
  end

  # Intermediate representation of boolean.
  def represent(value : Bool)
    YAML::Scalar.new(value ? "true" : "false", Tags::BOOL)
  end

  # Intermediate represention of Nil.
  def represent(value : Nil, tag : String = Tags::NULL)
    YAML::Scalar.new(nil, tag)
  end

  # Intermediate representation for all other types of objects.
  # For an object to to be representable it must support the
  # `#to_canonical` method.
  def represent(object, tag : String)
    represent(object.to_canonical, tag)
  end


  # Serialization

  # Serialize Nil.
  def serialize(none : Nil, emitter : YAML::Serializer)
    emitter.scalar("", tag(none))
  end

  # Serialize Bool.
  def serialize(bool : Bool, emitter : YAML::Serializer)
    emitter.scalar(bool, tag(bool))
  end

  # Serialize Number.
  def serialize(number : Number, emitter : YAML::Serializer)
    emitter.scalar(number.to_s, tag(number))
  end

  # Serialize Time using standard ISO format.
  def serialize(time : Time, emitter : YAML::Serializer)
    emitter.scalar(Time::Format::ISO_8601_DATE_TIME.format(time))
  end

end
