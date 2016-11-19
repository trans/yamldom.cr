class YAML::Scalar < YAML::Node
  @value    : String
  @tag      : String = Tags::STR
  @style    : LibYAML::ScalarStyle = LibYAML::ScalarStyle::ANY

  def initialize(value : String = "",
                 tag   : String = Tags::STR,
                 style : LibYAML::ScalarStyle = LibYAML::ScalarStyle::ANY)
    @value = value
    @tag = tag
    @style = style
  end

  def value
    @value
  end

  def value=(value : String)
    @value = value
  end

  def to_s
    @value
  end

  # TODO: tag should also be equal but also `"" == "tag:yaml.org,2002:str"`
  def ==(other : Scalar)
    value == other.value #&& tag == other.tag
  end

  def ==(other)
    false
  end

  def map
    yield self
  end

  # According to YAML spec, style is not a preseved attribute in
  # intermedaite representation beacuse it should never be used
  # to effect native data construction. However, it can be useful
  # for round-tripping when not going beyond the representation,
  # so we store is for that purpose.
  def style
    @style
  end

  def to_yaml(emitter : YAML::Emitter)
    emitter.scalar(self)
  end

  # TODO: Is the standard value of a null "" or "null"?
  def self.new(value : Nil, tag : String = "tag:yaml.org,2002:null")
    #YAML::Null.new(tag)
    new(value: "", tag: tag)
  end

  def self.new(value : Int, tag : String = "tag:yaml.org,2002:int")
    new(value: value.to_s, tag: tag)
  end

  def self.new(value : Float, tag : String = "tag:yaml.org,2002:float")
    new(value: value.to_s, tag: tag)
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


