class YAML::Stream

  def initialize(tag_schema : TagSchema)
    @tag_schema = tag_schema
  end

  # Load object from YAML.
  def load(yaml : String | IO)
    construct(compose(yaml))
  end

  # Dump object to YAML.
  def dump(object, io : IO)
    #serialize(represent(object), io)
    serialize(object, io)
  end

  def dump(object)
    #serialize(represent(value))
    serialize(object)
  end

  # Construction converts intermediate representation into native data types.
  def construct(node : Node)
    @tag_schema.construct(node)
  end

  # Representation converts native data types into intermediate representation.
  def represent(object) : Node
    @tag_schema.represent(object)
  end

  # Composition converts YAML format into intermediate representation.
  def compose(yaml : String | IO)
    Composer.new(yaml) do |composer|
      composer.compose #(yaml)
    end
  end

  # Serialization methods convert intermediate representation
  # int YAML format. Serialiation methods are also provided
  # for Crystal's built-in types directly -- without having
  # to go throught intermediate representation -- to improve
  # performance.

  # Serialize intermediate representation.
  def serialize(node : Node)
    @tag_schema.serialize(node)
  end

  # Serialize intermediate representation.
  def serialize(node : Node, io : IO)
    @tag_schema.serialize(node, io)
  end

  # Serialize native data type directly.
  def serialize(object)
    @tag_schema.serialize(object)
  end

  # Serialize native data type directly.
  def serialize(object, io : IO)
    @tag_schema.serialize(object, io)
  end

  # Access to cached serializer.
  #def serializer
  #  @serializer ||= Serializer.new(@tag_schema)
  #end

  #def composer
  #  @composer ||= Composer.new
  #end

end
