class YAML::Mapping < YAML::Collection
  include Enumerable({Value, Value})

  @value : Hash(Node, Node)
  @tag   : String = Tags::MAP
  @style : LibYAML::MappingStyle = LibYAML::MappingStyle::ANY

  def self.new(hash : Hash, tag : String = Tags::MAP)
    map = new(tag: tag)
    map.merge!(hash)
    map
  end

  def initialize
    @value = Hash(Node, Node).new
    @tag   = Tags::MAP
    @style = LibYAML::MappingStyle::ANY
  end

  def initialize(tag : String, style : LibYAML::MappingStyle = LibYAML::MappingStyle::ANY)
    @value = Hash(Node, Node).new
    @tag   = tag
    @style = style
  end

  def initialize(value : Hash(Node, Node),
                 tag   : String = Tags::MAP,
                 style : LibYAML::MappingStyle = LibYAML::MappingStyle::ANY)
    @value = value
    @tag   = tag
    @style = style
  end

  # The underlying Hash of nodes.
  getter value

  # Access to the LibYAML::MappingStyle of the node.
  getter style

  # Adjust the style. Valid values are:
  #
  # * LibYAML::MappingStyle::ANY
  # * LibYAML::MappingStyle::BLOCK
  # * LibYAML::MappingStyle::FLOW
  #
  def style=(scalar_style : LibYAML::MappingStyle)
    @style = scalar_style
  end

  # The conical tag is never an empty string. If the regular `tag` is empty then
  # `canonical_tag` is the standard `tag:yaml.org,2002:map`, otherwise it is the
  # same as `tag`.
  def canonical_tag
    if @tag.empty?
      Tags::MAP
    else
      @tag
    end
  end

  def nodes
    @value
  end

  # Get the associated node given a matching node key.
  def node(key : Node)
    @value[key]
  end

  # Get the associated node given a matching key.
  def node(key)
    @value[Node.new(key)]
  end

  # Looking up map entry using a Node key, will return the value as a Node.
  # This is the same as `#get`.
  def [](key : Node)
    @value[key]
  end

  # Does not return the node, but the value of the node. This makes it much
  # easier to work with the data.
  # ```crystal
  # data["invoice"]  #=> "84483"
  # ```
  # To get the node itself use `#get` instead.
  def [](key)
    @value[Node.new(key)].try &.value
  end

  def []=(key : Node, value : Node)
    @value[key] = value
  end

  def []=(key, value : Node)
    @value[Node.new(key)] = value
  end

  def []=(key : Node, value)
    @value[key] = Node.new(value)
  end

  def []=(key, value)
    @value[Node.new(key)] = Node.new(value)
  end

  # Insert a key,value pair into the mapping.
  def <<(t : Tuple)
    raise "" if t.size != 2
    self[t[0]] = t[1]
  end

  # Same as `#merge!`.
  def <<(nt : NamedTuple)
    merge!(nt)
  end

  # Merge another Mapping into this Mapping.
  def merge!(other : Mapping)
    @value.merge!(other.value)
  end

  def merge!(nt : NamedTuple)
    nt.each do |k,v|
      self[k] = v
    end
  end

  # Merge a Hash into this Mapping.
  def merge!(other : Hash)
    other.each do |k,v|
      self[k] = v
    end
  end

  # Merge a NamedTuple into this Mapping.
  def merge!(other : NamedTuple)
    other.each do |k,v|
      self[k] = v
    end
  end

  # Two mappings are equal if their values and canonical tags are the same.
  def ==(other : Mapping)
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
    @value.size
  end

  # Iterate over each tuple of `key node => value node` in the mapping.
  def each
    @value.each do |k,v|
      yield(k.value, v.value)
    end
  end

  # Iterate over each key node.
  def each_key
    @value.each_key do |k|
      yield k.value
    end
  end

  # Iterate over each value node.
  def each_value
    @value.each_value do |v|
      yield v.value
    end
  end

  # Iterate over the nodes in the sequence.
  def each_node
    @value.each do |t|
      yield t
    end
  end

  def each_node
    NodeIterator.new(self)
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
