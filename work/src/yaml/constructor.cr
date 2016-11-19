# @deprecated
#
# YAML Constructor takes intermediate representation and converts
# it to native data structures.
#
# If you have custom tags, you can create your own constructor
# by subclassing this class and passing an instance of it to
# `YAML.load`, or calling `load` on the class itself.
#
# When creating you own constructor, be sure to override `types`
# to return a type alias of all the concrete types your constructor
# can produce, and include Array and Hash of that alias as well.
# Here is an example.
#
# ```
# class MyConstructor < YAML::Constructor
#   alias MyTypes = Nil | String | Array(MyTypes) | Hash(MyTypes)
#   def types
#     MyTypes
#   end
# end
# ```
#
# Unfortunately this is neccessary becuase Crystal's type inference
# engine gets confused without it.
#
# TODO: Reverse process, supporting "deconstruction" for emitter?
#
class YAML::Constructor

  def self.load(content : String | IO)
    constructor = new
    constructor.construct(compose(content))
  end

  def self.load_stream(content : String | IO)
    constructor = new
    compose_stream(content).map{ |root| constructor.construct(root) }
  end

  alias Types = Nil | Bool | Int64 | Float64 | String | Array(Types) | Hash(Types, Types)

  def typify(x : Types)
    x.as(Types)
  end

  #
  # Implicit conversions
  #
  def construct_implicit(value : String)
    case value
    when /^\d+$/
      value.to_i64
    when /^\d*[.]\d+$/
      value.to_f64
    else
      value
    end
  end

  def construct_implicit(value : Nil)
    nil
  end

  #
  #
  #
  def construct(node : Scalar)
    case node.tag
    when "tag:yaml.org,2002:str"
      node.value
    else
      construct_implicit(node.value)
    end
  end

  #
  #
  #
  def construct(node : Sequence)
    node.map{ |n| typify(construct(n)) }
  end

  #
  #
  #
  def construct(node : Mapping)
    keys = node.map{ |k,v| typify(construct(k)) }
    vals = node.map{ |k,v| typify(construct(v)) }
    Hash.zip(keys, vals)
  end

  # Would be cool if we could use literal arguments.

  #def construct("tag:yaml.org,2002:str", value : String)
  #  value
  #end

  #def construct("tag:yaml.org,2002:map", value : Hash)
  #  value
  #end

  #def construct("tag:yaml.org,2002:seq", value : Array)
  #  value
  #end

end
