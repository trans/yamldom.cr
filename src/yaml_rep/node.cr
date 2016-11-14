##
# The abstract Node class is the base class of the three kinds: Scalar,
# Sequence and Mapping.
#
abstract class YAML::Node

  # TODO: Can tag be nil? Should we allow it to be nil?
  @tag : String

  def initialize(tag : String = "")
    @tag = tag
  end

  # Canonical tag provided by LibYAML.
  getter tag

  # Set tag to given string.
  #
  # TODO: Do we really need this?
  def tag=(tag : String)
    @tag = tag
  end

end
