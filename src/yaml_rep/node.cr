module YAML::Representation

	##
	#
	class Node
		@tag : String?

		getter tag

		def tag=(tag : String?)
		  @tag = tag
		end
	end

end
