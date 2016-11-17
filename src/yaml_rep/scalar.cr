#
class YAML::Scalar < YAML::Node
  @value : String
  @tag : String

  def initialize(value : String, tag : String)
    @value = value
    @tag = tag
  end

  def value
    @value
  end

  def value=(value : String)
    @value = value
  end

  def map
    yield self
  end

  def to_s
    @value.to_s
  end

  #def to(string_class : String.class)
  #  string_class.new(@value)
  #end

  # TODO: Is the standard value of a null "" or "null"?
  def self.new(value : Nil, tag : String = "tag:yaml.org,2002:null")
    #YAML::Null.new(tag)
    new("", tag)
  end

  def self.new(value : Int, tag : String = "tag:yaml.org,2002:int")
    new(value.to_s, tag)
  end

  def self.new(value : Float, tag : String = "tag:yaml.org,2002:float")
    new(value.to_s, tag)
  end

end

# Null is just a Scalar but used especially for `nil` value.
# We use this extra class to make it easier on the compiler
# avoiding those dreaded "not defined for Nil" errors.
#
#class YAML::Null < YAML::Node
#  def initialize(tag : String)
#    @tag = tag
#  end
#
#  def value
#    nil
#  end
#
#  def to_s
#    "null"
#  end
#end

