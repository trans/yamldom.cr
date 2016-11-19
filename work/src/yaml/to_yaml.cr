class Object

  def to_yaml(schema : YAML::TagSchema? = nil)
    node = YAML.dump(self, schema)
  end

end

struct Number
  def to_canonical
    self
  end
end


def Int8.from_canonical(value : Int8); value; end
def Int16.from_canonical(value : Int16); value; end
def Int32.from_canonical(value : Int32); value; end
def Int64.from_canonical(value : Int64); value; end

def UInt8.from_canonical(value : UInt8); value; end
def UInt16.from_canonical(value : UInt16); value; end
def UInt32.from_canonical(value : UInt32); value; end
def UInt64.from_canonical(value : UInt64); value; end

def Float64.from_canonical(value : Float64); value; end

class String
  def self.from_canonical(value : String)
    value
  end
  def to_canonical
    self
  end
end

class Array
  def self.from_canonical(value : Array<T>)
    map{ |e| T.from_canonical(e) }
  end
  def to_canonical
    map{ |e| e.to_canonical }
  end
end

