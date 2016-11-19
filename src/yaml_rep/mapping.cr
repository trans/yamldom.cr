class YAML::Mapping < YAML::Collection
  include Enumerable({Node, Node})

  @value : Hash(Node, Node)
  @tag   : String = Tags::MAP
  @style : LibYAML::MappingStyle = LibYAML::MappingStyle::ANY

  def initialize(value : Hash(Node, Node),
                 tag   : String = Tags::MAP,
                 style : LibYAML::MappingStyle = LibYAML::MappingStyle::ANY)
    @value = value
    @tag = tag
    @style = style
  end

  def initialize(tag : String, style : LibYAML::MappingStyle = LibYAML::MappingStyle::ANY)
    @value = Hash(Node, Node).new
    @tag = tag
    @style = style
  end

  getter value
  getter style

  def merge!(node : Mapping)
    @value.merge!(node.value)
  end

  def []=(key : Node, value : Node)
    @value[key] = value
  end

  def [](key : Node)
    @value[key]
  end

  def [](key)
    @value[Node.new(key)].try &.value
  end

  # TODO: tag should also be equal but also `"" == "tag:yaml.org,2002:map"`
  def ==(other : Mapping)
    value == other.value #&& tag == other.tag
  end

  def ==(other)
    false
  end

  def size
    @value.size
  end

  def each
    @value.each do |t|
      yield t
    end
  end

  def each_key
    @value.each_key do |k|
      yield k
    end
  end

  def each_value
    @value.each_value do |v|
      yield v
    end
  end

  def to_yaml(emitter : YAML::Emitter)
    emitter.mapping(@tag) do
      each do |key, value|
        key.to_yaml(emitter)
        value.to_yaml(emitter)
      end
    end
  end
end
