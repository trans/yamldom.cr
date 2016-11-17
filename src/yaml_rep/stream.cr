class YAML::Stream

  def initialize(tag_schema : TagSchema)
    @tag_schema = tag_schema
  end

  def load(source : String | IO)
    construct(compose(source))
  end

  def dump(value, io : IO)
    #serialize(represent(value), io)
    serialize(value, io)
  end

  def dump(value)
    #serialize(represent(value))
    serialize(value)
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

  def serialize(object)
    serializer.serialize(object)
  end

  def serialize(object, io : IO)
    serializer.serialize(object, io)
  end

  def serializer
    @serializer ||= Serializer.new(@tag_schema)
  end

  #def composer
  #  @composer ||= Composer.new
  #end

end


