module YAML::Representation

	##
	#
	class Scalar < Node
		@value : String?

		getter value

		def initialize(tag : String?, value : String?)
		  @tag = tag
		  @value = value 
		end

		def value=(value : String?)
		  @value = value
		end

    def to_s
      @value.to_s
    end

    def to(string_class : String.class)
      string_class.new(@value)
    end
	end

end
