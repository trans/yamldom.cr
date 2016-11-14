class YAML::Stream

  def initialize(tag_schema : TagSchema)
    @tag_schema = tag_schema
  end

  def load(source : String | IO)
    construct(compose(source))
  end

  def dump(value, io : IO)
    serialize(represent(value))
  end

  def dump(value)
    serialize(represent(value))
  end

  def construct(node : Node)
    @tag_schema.construct(node)
  end

  def represent(value) : Node
    @tag_schema.represent(value)
  end

  def compose(source : String | IO)
    Composer.new(source) do |composer|
      composer.compose #(source)
    end
  end

  def serialize(node : Node)
    serializer.serialize(node)
  end

  def serialize(node : Node, io : IO)
    serializer.serialize(node, io)
  end

  #def composer
  #  @composer ||= Composer.new
  #end

end


