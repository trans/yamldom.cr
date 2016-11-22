class YAML::Scalar < YAML::Node
  include Enumerable(String)

  @value    : String
  @tag      : String = Tags::STR
  @style    : LibYAML::ScalarStyle = LibYAML::ScalarStyle::ANY

  def initialize(value : String = "",
                 tag   : String = Tags::STR,
                 style : LibYAML::ScalarStyle = LibYAML::ScalarStyle::ANY)
    @value = value
    @tag   = tag
    @style = style
  end

  def value
    @value
  end

  # TODO: Accept any object that support `#to_s`?
  def value=(value : String)
    @value = value
  end

  def canonical_tag
    if @tag.empty?
      Tags::STR
    else
      @tag
    end
  end

  #def bytesize
  # @value.bytesize
  #end

  # Return the underlying value as a string -- which in this case it already is.
  def to_s
    @value.to_s
  end

  # Two scalars are equal if their values and canonical tags are the same.
  def ==(other : Scalar)
    value == other.value && canonical_tag == other.canonical_tag
  end

  # Comparison to any other type produces `false`.
  def ==(other)
    false
  end

  def hash
    {value, canonical_tag}.hash
  end

  # Of course, the size of a scalar is `1`.
  def size
    1
  end

  # Iterate over the value once.
  def each
    yield value
  end

  # Iterate over itself once.
  def each_node
    yield self
  end

  def node
    self
  end

  def node(any)
    raise Error.new("wrong number of arguments for 'YAML::#{self.class}#node' (given 1, expected 0)")
  end

  # :nodoc:
  def [](key)
    raise Error.new("no overload matches 'YAML::#{self.class}#[]' with type #{key.class}")
  end

  # :nodoc:
  def []=(key, value)
    raise Error.new("no overload matches 'YAML::#{self.class}#[]=' with type #{key.class}, #{value.class}")
  end

  # According to YAML spec, style is not a preseved attribute in
  # intermedaite representation beacuse it should never be used
  # to effect native data construction. However, it can be useful
  # for round-tripping when not going beyond the representation,
  # so we store is for that purpose.
  def style
    @style
  end

  # Adjust the style. Valid values are:
  #
  # * LibYAML::ScalarStyle::ANY
  # * LibYAML::ScalarStyle::PLAIN
  # * LibYAML::ScalarStyle::SINGLE_QUOTED
  # * LibYAML::ScalarStyle::DOUBLE_QUOTED
  # * LibYAML::ScalarStyle::LITERAL
  # * LibYAML::ScalarStyle::FOLDED
  #
  def style=(scalar_style : LibYAML::ScalarStyle)
    @style = scalar_style
  end

  # Serialize to YAML format given a YAML::Emitter instance.
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

  def self.new(value : Bool, tag : String = "tag:yaml.org,2002:bool")
    new(value: value.to_s, tag: tag)
  end

end
