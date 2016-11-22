# The abstract Node class is the base class for the three kinds of YAML
# nodes: `Scalar`, `Sequence` and `Mapping`.
abstract class YAML::Node
  @tag : String = ""

  #def initialize(tag : String = "")
  #  @tag = tag
  #end

  # Canonical tag provided by LibYAML.
  getter tag

  # Set tag to given string.
  #
  # TODO: Do we really need this?
  def tag=(tag : String)
    @tag = tag
  end

  def self.new(object : String)
    Scalar.new(object)
  end

  def as_str
    self.as(Scalar)
  end

  def as_seq
    self.as(Seqeunce)
  end

  def as_map
    self.as(Mapping)
  end

  # TODO: Add other factory methods.

  def self.new(value : String, tag : String = "tag:yaml.org,2002:str")
    Scalar.new(value: value, tag: tag)
  end

  # Symbols are converted to strings.
  def self.new(value : Symbol, tag : String = "tag:yaml.org,2002:str")
    Scalar.new(value: value.to_s, tag: tag)
  end

  def self.new(value : Nil, tag : String = "tag:yaml.org,2002:null")
    Scalar.new(value: "", tag: tag)
  end

  def self.new(value : Int, tag : String = "tag:yaml.org,2002:int")
    Scalar.new(value: value.to_s, tag: tag)
  end

  def self.new(value : Float, tag : String = "tag:yaml.org,2002:float")
    Scalar.new(value: value.to_s, tag: tag)
  end

  def self.new(value : Bool, tag : String = "tag:yaml.org,2002:bool")
    Scalar.new(value: value.to_s, tag: tag)
  end

  def self.new(array : Array, tag : String = "tag:yaml.org,2002:seq")
    Sequence.new(array, tag: tag)
  end

  # TODO: What about Hash map?
end
