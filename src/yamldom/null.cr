# Null is just a Scalar but used especially for `nil` value.
# We use this extra class to make it easier on the compiler
# avoiding those dreaded "not defined for Nil" errors.
#
# IMPORTANT: This class is no being used!!! It's here in case
# we decided to use it in the future. If we do not, eventually
# it will be removed.
#
class YAML::Null < YAML::Node
  def initialize(value : String, tag : String)
    @value = value
    @tag = tag
  end

  # This is the main difference between using Null vs Scalar for nil.
  def value
    nil
  end

  def to_s
    @value
  end

  def [](key)
    nil
  end
end


