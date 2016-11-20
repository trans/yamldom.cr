class YAML::Scalar < YAML::Node
  include Enumerable(Node)

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

  def size
    1
  end

  def each
    yield self
  end

  def [](key)
    raise Error.new("no overload matches 'YAML::#{self.class}#[]' with type #{key.class}")
  end

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

  def self.new(array : Array, tag : String = "tag:yaml.org,2002:seq")
    value = array.map{ |x| x.is_a?(Node) ? x : new(x) }
    new(value: value, tag: tag)
  end

  # TODO: Waht about Hash map?
end
