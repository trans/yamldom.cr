class YAML::Sequence < YAML::Collection
  include Enumerable(String | Array(Node) | Hash(Node,Node))

  @value : Array(Node)
  @tag   : String = Tags::SEQ
  @style : LibYAML::SequenceStyle = LibYAML::SequenceStyle::ANY

  def self.new(array : Array, tag : String = Tags::SEQ)
    seq = new(tag: tag)
    array.each do |x|
      seq << x #.is_a?(Node) ? x : Node.new(x) }
    end
    seq
  end

  def initialize(value : Array(Node),
                 tag   : String = Tags::SEQ,
                 style : LibYAML::SequenceStyle = LibYAML::SequenceStyle::ANY)
    @value = value
    @tag   = tag
    @style = style
  end

  def initialize(tag : String = Tags::SEQ, style : LibYAML::SequenceStyle = LibYAML::SequenceStyle::ANY)
    @value = Array(Node).new
    @tag   = tag
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

  # Anything else appended to the sequence has to be converted to a node.
  def <<(object)
    @value << Node.new(object)
  end

  # Length of the sequence.
  def size
    @value.size
  end

  # Iterate over the node values in the sequence.
  def each
    @value.each do |n|
      yield n.value
    end
  end

  # Iterate over the node values in the sequence.
  def each
    @value.each do |n|
      yield n.value, nil
    end
  end

  def each
    ValueIterator.new(self)
  end

  # Iterate over the nodes in the sequence.
  def each_node
    @value.each do |n|
      yield n
    end
  end

  def each_node
    NodeIterator.new(self)
  end

  # Get a node by its position in the sequence.
  def node(index : Int)
    @value[index]
  end

  # :nodoc:
  def node(any)
    raise Error.new("no overload matches 'YAML::#{self.class}#[]' with type #{any.class}")
  end

  def nodes
    @value
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

  # Adjust the style. Valid values are:
  #
  # * LibYAML::SequenceStyle::ANY
  # * LibYAML::SequenceStyle::BLOCK
  # * LibYAML::SequenceStyle::FLOW
  #
  def style=(scalar_style : LibYAML::SequenceStyle)
    @style = scalar_style
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

  private class NodeIterator
    include Iterator(Node)
    def initialize(@sequence : Sequence)
      @size  = @seq.size
      @count = 0
    end
    def next
      if @count < @size
        @count += 1
        @sequence.get(@count - 1)
      else
        stop
      end
    end
    def rewind
      @count = 0
      self
    end
  end

  private class ValueIterator
    include Iterator(String | Array(Node) | Hash(Node,Node))
    def initialize(@sequence : Sequence)
      @size  = @seq.size
      @count = 0
    end
    def next
      if @count < @size
        @count += 1
        @sequence[@count - 1]
      else
        stop
      end
    end
    def rewind
      @count = 0
      self
    end
  end
end

