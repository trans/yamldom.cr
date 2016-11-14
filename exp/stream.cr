module YAML

  ##
  # YAML Stream
  #
  class Stream
    include Enumerable(Document)

		@documents : Array(Document)

    def initialize(documents : Array(Document))
      @documents = documents
    end

    def each(&block)
      @documents.each(&block)
    end

    def size
      @documents.size
    end

    def self.load(content : String | IO)
      Composer
      Stream.new( )
    end

    def self.load(content : IO)

      Stream.new( )
    end

  end

end
