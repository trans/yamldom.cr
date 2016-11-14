#
class YAML::Scalar < YAML::Node
  @tag : String
  @value : String

  getter value

  def initialize(tag : String, value : String)
    @tag = tag
    @value = value 
  end

  def value=(value : String?)
    @value = value
  end

  def to_s
    @value.to_s
  end

  def to(string_class : String.class)
    string_class.new(@value)
  end

  def map
    yield self
  end

  def self.new(tag : String, value : Nil)
    Null.new(tag)
  end
end

class YAML::Null < YAML::Node
  def initialize(tag : String)
    @tag = tag
  end
end
