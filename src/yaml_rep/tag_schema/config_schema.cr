# Config schema is the same as the CoreSchema but limits mapping keys to
# strings and symbols. This is particularly useful for configuration files.
class YAML::ConfigSchema < YAML::CoreSchema

  #alias KeyType = String | Symbol

  alias Type = Nil | Bool | Int64 | Float64 | String | Array(Type) | Hash(Type, Type)

  def as_type(value)
    value.as(Type)
  end

  def construct(node : YAML::Mapping)
    keys = node.map{ |k,v| construct_key(k) }
    vals = node.map{ |k,v| as_type(construct(v)) }
    Hash.zip(keys, vals)
  end

  def construct_key(node : YAML::Node)
    raise YAML::Error.new("bad configuration key, must be string")
  end

  def construct_key(node : YAML::Scalar)
    node.value.to_s
  end

end

