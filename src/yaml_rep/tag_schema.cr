# Base class for tag schemas.
#
abstract class YAML::TagSchema

  alias Type = Nil | String | Array(Type) | Hash(Type, Type)

  def as_type(value)
    value.as(Type)
  end

  #def load(content : String | IO)
  #  constructor = new
  #  constructor.construct(compose(content))
  #end

  #def load(content : String | IO)
  #  compose(content).map{ |root| construct(root) }
  #end

  #
  def construct(node : YAML::Null)
    nil
  end

  # Fallback is just original string value.
  def construct(node : YAML::Scalar)
    node.value
  end

  # Construct sequence with array.
  def construct(node : YAML::Sequence)
    node.map{ |n| as_type(construct(n)) }
  end

  # Construct mapping using hash.
  def construct(node : YAML::Mapping)
    keys = node.map{ |k,v| as_type(construct(k)) }
    vals = node.map{ |k,v| as_type(construct(v)) }
    Hash.zip(keys, vals)
  end

  def represent(value)
    Scalar.new(nil, value.to_s)
  end

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

# Very basic YAML tag schema that is compatiable with JSON. Includes
# implicit types for `null`, `bool` (`true` or `false`), `int` and `float`.
class YAML::JSONSchema < YAML::TagSchema

  alias Type = Nil | Bool | Int64 | Float64 | String | Array(Type) | Hash(Type, Type)

  def as_type(value)
    value.as(Type)
  end

  def construct(node : YAML::Scalar)
    case node.tag
    when "tag:yaml.org,2002:str"
      node.value
    when "tag:yaml.org,2002:int"
      construct_integer(node)
    when "tag:yaml.org,2002:float"
      construct_float(node)
    when "tag:yaml.org,2002:bool"
      construct_bool(node)
    when "tag:yaml.org,2002:null"
      nil
    else
      construct_implicit(node)
    end
  end

  # Implicit conversions
  def construct_implicit(node : YAML::Scalar)
    case value = node.value
    when /-? ( 0 | [1-9] [0-9]* )/
      value.to_i64
    when /-? ( 0 | [1-9] [0-9]* ) ( \. [0-9]* )? ( [eE] [-+]? [0-9]+ )?/
      value.to_f64
    when "true"
      true
    when "false"
      false
    when "null"
      nil
    else
      # TODO proper YAML error
      raise "Invalid scalar"
    end
  end

  def construct_integer(node : YAML::Scalar)
    case value = node.value
    when /-? ( 0 | [1-9] [0-9]* )/
      value.to_i64
    else
      raise "invalid integer scalar"
    end
  end

  def construct_float(node : YAML::Scalar)
    case value = node.value
    when /-? ( 0 | [1-9] [0-9]* ) ( \. [0-9]* )? ( [eE] [-+]? [0-9]+ )?/
      value.to_f64
    else
      raise "invalid float scalar"
    end
  end

  def construct_bool(node : YAML::Scalar)
    case node.value
    when "true"
      true
    when "false"
      false
    else
      raise "invalid boolean scalar"
    end
  end

  def represent(value : String)
    Scalar.new("tag:yaml.org,2002:str", value)
  end

  def represent(value : Int)
    Scalar.new("tag:yaml.org,2002:int", value.to_s)
  end

  def represent(value : Float)
    Scalar.new("tag:yaml.org,2002:float", value.to_s)
  end

  def represent(value : Bool)
    Scalar.new("tag:yaml.org,2002:bool", value ? "true" : "false")
  end

  def represent(value : Nil)
    Scalar.new("tag:yaml.org,2002:null", "null")
  end

end

# The standard YAML Core Schema.
class YAML::CoreSchema < YAML::TagSchema

  alias Type = Nil | Bool | Int64 | Float64 | String | Array(Type) | Hash(Type, Type)

  def as_type(value)
    value.as(Type)
  end

  def construct(node : YAML::Scalar)
    case node.tag
    when "tag:yaml.org,2002:str"
      node.value
    when "tag:yaml.org,2002:int"
      construct_integer(node)
    when "tag:yaml.org,2002:float"
      construct_float(node)
    when "tag:yaml.org,2002:bool"
      construct_bool(node)
    when "tag:yaml.org,2002:null"
      nil
    else
      construct_implicit(node)
    end
  end

  # Implicit conversions
  def construct_implicit(node : YAML::Scalar)
    case value = node.value
    when /[-+]? [0-9]+/
      value.to_i64
    when /0o [0-7]+/          # Base 8
      value.to_i64(8)
    when /0x [0-9a-fA-F]+/    # Base 16
      value.to_i64(16)
    when /[-+]? ( \. [0-9]+ | [0-9]+ ( \. [0-9]* )? ) ( [eE] [-+]? [0-9]+ )?/
      value.to_f64
    when /[+]?\.inf/i
      Float64::INFINITY
    when /[-]\.inf/i
      -Float64::INFINITY
    when /\.nan/i
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
    when /[-+]? [0-9]+/
      value.to_i64
    when /0o [0-7]+/          # Base 8
      value.to_i64(8)
    when /0x [0-9a-fA-F]+/    # Base 16
      value.to_i64(16)
    else
      raise "invalid integer scalar"
    end
  end

  def construct_float(node : YAML::Scalar)
    case value = node.value
    when /[-+]? ( \. [0-9]+ | [0-9]+ ( \. [0-9]* )? ) ( [eE] [-+]? [0-9]+ )?/
      value.to_f64
    when /[+]?\.inf/i
      Float64::INFINITY
    when /[-]\.inf/i
      -Float64::INFINITY
    when /\.nan/i
      Float64::NAN
    else
      raise "invalid float scalar"
    end
  end

  def construct_bool(node : YAML::Scalar)
    case node.value
    when /^true$/i
      true
    when /^false$/i
      false
    else
      raise "invalid boolean scalar"
    end
  end

  def represent(value : String)
    Scalar.new("tag:yaml.org,2002:str", value)
  end

  def represent(value : Int)
    Scalar.new("tag:yaml.org,2002:int", value.to_s)
  end

  def represent(value : Float)
    if value == Float::INFINITY
      Scalar.new("tag:yaml.org,2002:float", ".INF")
    elsif value == -Float::INFINITY
      Scalar.new("tag:yaml.org,2002:float", "-.INF")
    else
      Scalar.new("tag:yaml.org,2002:float", value.to_s)
    end
  end

  def represent(value : Bool)
    Scalar.new("tag:yaml.org,2002:bool", value ? "true" : "false")
  end

  def represent(value : Nil)
    Scalar.new("tag:yaml.org,2002:null", "")
  end

end

# Config stream limits mapping keys to strings/symbols.
class YAML::ConfigSchema < YAML::CoreSchema

  alias KeyType = String | Symbol

  alias ValueType = Nil | Bool | Int64 | Float64 | String | Array(ValueType) | Hash(KeyType, ValueType)

  def as_type(value)
    value.as(ValueType)
  end

  def construct(node : YAML::Mapping)
    keys = node.map{ |k,v| construct(k).as(KeyType) }
    vals = node.map{ |k,v| as_type(construct(v)) }
    Hash.zip(keys, vals)
  end

end

