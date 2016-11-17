# Most basic YAML tag schema that is compatiable with JSON.
# Includes implicit types for `string`, `null`, `bool`, `int` and `float`.
class YAML::JSONSchema < YAML::TagSchema

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

  def construct_integer(node : YAML::Scalar)
    case value = node.value
    when /-? ( 0 | [1-9] [0-9]* )/
      value.to_i64
    else
      raise YAML::Error.new("invalid integer scalar")
    end
  end

  def construct_float(node : YAML::Scalar)
    case value = node.value
    when /-? ( 0 | [1-9] [0-9]* ) ( \. [0-9]* )? ( [eE] [-+]? [0-9]+ )?/
      value.to_f64
    else
      raise YAML::Error.new("invalid float scalar")
    end
  end

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

  def represent(value : String, tag : String =  Tags::STR)
    YAML::Scalar.new(value, tag)
  end

  def represent(value : Int, tag : String = Tags::INT)
    YAML::Scalar.new(value.to_s, tag)
  end

  def represent(value : Float, tag : String = Tags::FLOAT)
    YAML::Scalar.new(value.to_s, tag)
  end

  def represent(value : Bool, tag : String = Tags::BOOL)
    YAML::Scalar.new(value ? "true" : "false", tag)
  end

  #def represent(value : Nil)
  #  YAML::Null.new("tag:yaml.org,2002:null")
  #end

end

