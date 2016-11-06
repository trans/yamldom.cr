module YAML

  ##
  #
  abstract class Node
    @tag : String

    getter tag

    def initialize
      @tag = ""
    end

    def tag=(tag : String)
      @tag = tag
    end
  end

end
