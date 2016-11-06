# YAML Constructor takes intermediate representation and converts it to native
# data structures.
#
# TODO: Reverse process
#
class YAML::Constructor

  DEFAULT_RECOGNIZER = DefaultRecognizer.new

  def initialize(recognizer : Recognizer = DEFAULT_RECOGNIZER)
    @recognizer = recognizer
  end

  def construct(node : Scalar)
    @recognizer.construct(node.tag, node.value)

    #if @register.tag?(node.tag)
    #  tag_class = @register[node.tag]
    #  tag_class.not_nil!.yaml_serialize(node.value)
    #else
    #  node.value
    #end
  end

  def construct(node : Sequence)
    array = node.map{ |n| construct(n) }

    @recognizer.construct(node.tag, array)

    #if @register.tag?(node.tag)
    #  tag_class = @register[node.tag]
    #  tag_class.not_nil!.yaml_serialize(a)
    #else
    #  a
    #end
  end

  def construct(node : Mapping)
    keys = node.map{ |k,v| construct(k) }
    vals = node.map{ |k,v| construct(v) }
    hash = Hash.zip(keys, vals)

    @recognizer.construct(node.tag, hash)

    #if @register.tag?(node.tag)
    #  tag_class = @register[node.tag]
    #  tag_class.not_nil!.yaml_serialize(h)
    #else
    #  h
    #end
  end

end
