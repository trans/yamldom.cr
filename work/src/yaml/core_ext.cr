class Array

  # TODO: Is there a way to reduce generic types to their minimum unions?
  def type_reduce
    self
  end

end

# These `#to_canonical` methods are really only defined on these
# native data types to keep Crystal's compiler happy. The method
# is generally only ever used for non-canonical types, i.e. non-primatives.
# Its purpose is to allow a class to define how its state should be
# represented in canonical form -- one that ultimately reduces to primative
# data types.


class String
  def self.from_canonical(value : String)
    value
  end
  def to_canonical
    self
  end
end

struct Number
  def to_canonical
    self
  end
end

class Array
  def to_canonical
    self
  end
end

class Hash
  def to_canonical
    self
  end
end

struct Tuple
  def to_canonical
    self
  end
end

struct NamedTuple
  def to_canonical
    self
  end
end

struct Nil
  def to_canonical
    self
  end
end

struct Bool
  def to_canonical
    self
  end
end

# TODO: Any others?

def Int8.from_canonical(value)
  value.to_i8
end

def Int16.from_canonical(value)
  value.to_i16
end

def Int32.from_canonical(value)
  value.to_i32
end

def Int64.from_canonical(value)
  value.to_i64
end

def Float32.from_canonical(value)
  value.to_f32
end

def Float64.from_canonical(value)
  value.to_f64
end

def Array.from_canonical(value)
  value
end

def Hash.from_canonical(value)
  value
end

def Nil.from_canonical(value)
  nil
end

def Bool.from_canonical(value)
  case value
  when String
    true if value == "true"
  else
    value
  end
end

