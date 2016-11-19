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

  getter value
  getter style

  def <<(node : Node)
    @value << node
  end

  def size
    @value.size
  end

  def each
    @value.each do |v|
      yield v
    end
  end

  def to_yaml(emitter : YAML::Emitter)
    emitter.sequence(@tag) do
      each &.to_yaml(emitter)
    end
  end

end

