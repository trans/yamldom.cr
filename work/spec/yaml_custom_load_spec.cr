

PERSON_LIST_YAML = <<-YAML
---
- !person
  name: Jack
  age: 302001-01-23
- !person
  name: Tim
  age: 42
YAML

class Person
  def self.from_canonical(canonical)
    new(canonical["name"].as(String), canonical["age"].as(Int64))
  end
  def initialize(@name : String, @age : Int64)
  end
  def to_canonical
    { "name" => @name, "age" => @age }
  end
end

class YAML::PersonSchema < YAML::CoreSchema
  def tag(person : Person)
    "!person"
  end

  def type(tag : String)
    if tag == "!person"
      Person
    else
      super(tag)
    end
  end

  #def construct(node : YAML::Mapping)
  #  r = super(node)
  #  if node.tag == "!person"
  #    Person.new(r["name"].as(String), r["age"].as(Int64))
  #  else
  #    r
  #  end
  #end
end

describe YAML do
  data = YAML.compose(PERSON_LIST_YAML, PersonSchema.new)
end

