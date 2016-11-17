class Array

  # TODO: Is there a way to reduce element types to minimum unions?
  def type_reduce
    self
  end

end

class String
  def to_canonical
    self
  end
end

struct Number
  def to_canonical
    self
  end
end

