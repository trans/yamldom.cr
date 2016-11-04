module YAML::Representation

  class Document
    include Enumerable(Node)

    @node : Node

    def initialize(node : Node)
      @node = node
    end

    def tag
      @node.tag
    end

    def root
      @node
    end

    def each(&block)
      @node.each(&block)
    end

    def size
      @node.size
    end
  end

end
