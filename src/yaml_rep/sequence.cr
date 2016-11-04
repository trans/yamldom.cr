module YAML::Representation

	##
	#
	class Sequence < Node
		include Enumerable(Node)

		@value : Array(Node)

		getter value

		def initialize(tag : String?)
		  @tag = tag
		  @value = Array(Node).new 
		end

		def <<(node : Node)
		  @value << node
		end

		def each
		  @value.each do |v|
		    yield v
		  end
		end

		def size
		  @value.size
		end
	end

end
