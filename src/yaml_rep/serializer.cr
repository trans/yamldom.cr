# TODO: Don't think we need separate Emitter class, it's code can be incorporated into Serializer.

# Serializer converts intermediate representation into a serialization of events.
# This class interfaces with LibYAML which takes care of the final leg of createing a
# character stream to produce the final YAML document.
#
class YAML::Serializer

  def initialize()
  end

  def serialize(node : Node)
    serialize([node])
  end

  def serialize(node : Node, io : IO)
    serialize([node], io)
  end

  def serialize(nodes : Array(Node))
    String.build do |str_io|
      serialize(nodes, str_io)
    end
  end

  def serialize(nodes : Array(Node), io : IO)
    YAML::Emitter.new(io) do |emitter|
      emitter.stream do
        nodes.each do |node|
          emitter.document do
            serialize_node(emitter, node)
          end
        end
      end
    end
  end

  def serialize_node(emitter : Emitter, node : Scalar)
    emitter.scalar(node.value, node.tag)
  end

  def serialize_node(emitter : Emitter, node : Sequence)
    emitter.sequence do
      node.each do |n|
        serialize(n) 
      end
    end
  end

  def serialize_node(emitter : Emitter, node : Mapping)
    emitter.mapping do
      node.each do |k, v|
        serialize(k)
        serialize(v)
      end
    end
  end

end
