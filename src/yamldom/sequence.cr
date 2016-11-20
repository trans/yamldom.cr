class YAML::Sequence < YAML::Collection
  include Enumerable(Node)

  @value : Array(Node)
  @tag   : String = Tags::SEQ
  @style : LibYAML::SequenceStyle = LibYAML::SequenceStyle::ANY

  def initialize(value : Array(Node),
                 tag   : String = Tags::SEQ,
                 style : LibYAML::SequenceStyle = LibYAML::SequenceStyle::ANY)
    @value = value
    @tag = tag
    @style = style
  end

  def initialize(tag : String, style : LibYAML::SequenceStyle = LibYAML::SequenceStyle::ANY)
    @value = Array(Node).new
    @tag = tag
    @style = style
  end

  # The underlying array of contained nodes.
  getter value

  # Access to the LibYAML::SequenceStyle of the node.
  getter style

  # The conical tag is never an empty string. If the regular `tag` is empty then
  # `canonical_tag` is the standard `tag:yaml.org,2002:seq`, otherwise it is the
  # same as `tag`.
  def canonical_tag
    if @tag.empty?
      Tags::SEQ
    else
      @tag
    end
  end

  # Append a node to the end of the sequence.
  def <<(node : Node)
    @value << node
  end

  # Length of the sequence.
  def size
    @value.size
  end

  # Iteratge over the nodes in the sequence.
  def each
    @value.each do |n|
      yield n
    end
  end

  # Get a node by its position in the sequence.
  def get(index : Int)
    @value[index]
  end

  # This does not return the node, but the node's value.
  # To get the node by index, use `#get`.
  def [](index : Int)
    @value[index].try &.value
  end

  # :nodoc:
  def [](index)
    raise Error.new("no overload matches 'YAML::#{self.class}#[]' with type #{index.class}")
  end

  def []=(index : Int, node : Node)
    @value[index] = node
  end

  def []=(index : Int, value)
    @value[index] = Node.new(value)
  end

  # Two sequences are equal if their values and canonical tags are the same.
  def ==(other : Sequence)
    value == other.value && canonical_tag == other.canonical_tag
  end

  # Comparison to any other type produces `false`.
  def ==(other)
    false
  end

  # Hash identifier for determining equality.
  def hash
    {value, canonical_tag}.hash
  end

  def to_yaml(emitter : YAML::Emitter)
    emitter.sequence(@tag) do
      each &.to_yaml(emitter)
    end
  end

end

