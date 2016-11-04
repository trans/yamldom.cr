module YAML::Representation

	##
	#
	class Mapping < Node
		include Enumerable(Hash(Node, Node))

		@value : Hash(Node, Node)

		getter value

		def initialize(tag : String?)
      @tag = tag
		  @value = Hash(Node, Node).new 
		end

		def merge!(value : Mapping)
		  @value.merge!(value.value)
		end

		def []=(key : Node, value : Node)
		  @value[key] = value
		end

		def [](key : Node, value : Node)
		  @value[key] = value
		end

		def each
		  @value.each do |k,v|
		    yield k,v
		  end
		end

		def size
		  @value.size
		end
	end

end
