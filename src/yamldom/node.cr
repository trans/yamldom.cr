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
end
