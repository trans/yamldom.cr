module YAML

  ##
  #
  class Mapping < Node
    include Enumerable({Node, Node})

    @value : Hash(Node, Node)

    getter value

    def initialize(tag : String)
      @tag = tag
      @value = Hash(Node, Node).new 
    end

    def merge!(node : Mapping)
      @value.merge!(node.value)
    end

    def []=(key : Node, value : Node)
      @value[key] = value
    end

    def [](key : Node, value : Node)
      @value[key] = value
    end

    def size
      @value.size
    end

    def each
      @value.each do |t|
        yield t
      end
    end

    def each_key
      @value.each_key do |k|
        yield k
      end
    end

    def each_value
      @value.each_value do |v|
        yield v
      end
    end

  end

end
