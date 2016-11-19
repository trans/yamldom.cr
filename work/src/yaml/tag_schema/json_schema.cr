# Most basic YAML tag schema that is compatiable with JSON.
# Includes implicit types for `string`, `null`, `bool`, `int` and `float`.
class YAML::JSONSchema < YAML::TagSchema

  # Canonical types JSONSchema produces.
  #alias Type = Nil | Bool | Int64 | Float64 | String | Array(Type) | Hash(Type, Type)
  #def as_type(value)
  #  value.as(Type)
  #end

  # Tag methods are used to look the schema tag for a given object.

  def tag(object : String) ; Tags::STR   ; end
  def tag(object : Int)    ; Tags::INT   ; end
  def tag(object : Float)  ; Tags::FLOAT ; end
  def tag(object : Bool)   ; Tags::BOOL  ; end
  def tag(object : Nil)    ; Tags::NULL  ; end

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
    when /^[-]?(0|[1-9][0-9]*)$/
      value.to_i64
    when /^[-]?(0|[1-9][0-9]*)(\.[0-9]*)?([eE][-+]?[0-9]+)?$/
      value.to_f64
    when "true"
      true
    when "false"
      false
    when "null"
      nil
    else
      raise YAML::Error.new("invalid scalar")
    end
  end

  # Construct integer.
  def construct_integer(node : YAML::Scalar)
    case value = node.value
    when /[-]?(0|[1-9][0-9]*)/
      value.to_i64
    else
      raise YAML::Error.new("invalid integer scalar")
    end
  end

  # Construct float.
  def construct_float(node : YAML::Scalar)
    case value = node.value
    when /[-]?(0|[1-9][0-9]*)(\.[0-9]*)?([eE][-+]?[0-9]+)?/
      value.to_f64
    else
      raise YAML::Error.new("invalid float scalar")
    end
  end

  # Construct boolean.
  def construct_bool(node : YAML::Scalar)
    case node.value
    when "true"
      true
    when "false"
      false
    else
      raise YAML::Error.new("invalid boolean scalar")
    end
  end

  # Representation methods convert native data types to
  # intermediate representations.

  # Intermediate representation of String.
  def represent(value : String, tag : String = Tags::STR)
    YAML::Scalar.new(value, tag)
  end

  # Intermediate representation of Int.
  def represent(value : Int, tag : String = Tags::INT)
    YAML::Scalar.new(value.to_s, tag)
  end

  # Intermediate representation of Float.
  def represent(value : Float, tag : String = Tags::FLOAT)
    YAML::Scalar.new(value.to_s, tag)
  end

  # Intermediate representation of Bool.
  def represent(value : Bool, tag : String = Tags::BOOL)
    YAML::Scalar.new(value ? "true" : "false", tag)
  end

  # Intermediate represention of Nil.
  def represent(value : Nil, tag : String = Tags::NULL)
    YAML::Scalar.new("null", tag)
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
    emitter.scalar("null", tag(none))
  end

  # Serialize Bool.
  def serialize(bool : Bool, emitter : YAML::Serializer)
    emitter.scalar(bool, tag(bool))
  end

  # Serialize Number.
  def serialize(number : Number, emitter : YAML::Serializer)
    emitter.scalar(number.to_s, tag(number))
  end

end
