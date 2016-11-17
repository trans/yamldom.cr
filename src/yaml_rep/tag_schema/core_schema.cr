# Standard YAML Core Schema. This schema handles all the data types specified by
# the YAML 1.2 core standard.
#
class YAML::CoreSchema < YAML::TagSchema

  alias Type = Nil | Bool | Int64 | Float64 | String | Array(Type) | Hash(Type, Type)

  def as_type(value)
    value.as(Type)
  end

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

  # Implicit conversions
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

  def represent(value : Int)
    Scalar.new(value.to_s, Tags::INT)
  end

  def represent(value : Float)
    if value == Float::INFINITY
      Scalar.new(".INF", Tags::FLOAT)
    elsif value == -Float::INFINITY
      Scalar.new("-.INF", Tags::FLOAT)
    else
      Scalar.new(value.to_s, Tags::FLOAT)
    end
  end

  def represent(value : Bool)
    Scalar.new(value ? "true" : "false", Tags::BOOL)
  end

  def represent(value : Nil)
    Scalar.new("", Tags::NULL)
  end

end
