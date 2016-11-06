# YAML Serializer takes intermediate representation and converts it to native
# data structures.
#
class YAML::Serializer

  def initialize(register : Tag::Register = nil)
    @register = register || YAML::Tag.register
  end

  def serialize(node : Scalar)
    if @register.tag?(node.tag)
      tag_class = @register[node.tag]
      tag_class.not_nil!.yaml_serialize(node.value)
    else
      node.value
    end
  end

  def serialize(node : Sequence)
    a = node.map{ |n| serialize(n) }

    if @register.tag?(node.tag)
      tag_class = @register[node.tag]
      tag_class.not_nil!.yaml_serialize(a)
    else
      a
    end
  end

  def serialize(node : Mapping)
    keys = node.map{ |k,v| serialize(k) }
    vals = node.map{ |k,v| serialize(v) }
    h = Hash.zip(keys, vals)

    if @register.tag?(node.tag)
      tag_class = @register[node.tag]
      tag_class.not_nil!.yaml_serialize(h)
    else
      h
    end
  end

end
