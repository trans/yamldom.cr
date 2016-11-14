#
# NOTE: Class instance is not yet being used, not sure we need it
#       since LibYAML takes care of tag parsing for us.
#
class YAML::Tag

  def initialize(fullname : String)
    @fullname = fullname
  end

  def local?
    @fullname[0] == "!" && @fullname [1] != "!"
  end

  # Extract URI from tag, if is contains one. ?
  def uri
    # TODO
  end

#  #
#  # Global tag register is the default register used when serializing.
#  #
#  @@register : Hash(String, Tuple(String, Class)Register = Register.new

#  #
#  #
#  #
#  def self.register
#    @@register
#  end

#  # 
#  # Returns class associated with given tag.
#  #
#  def self.[](tag : String)
#    @@register[tag]
#  end

#  # 
#  # Returns an array of tags associated with a class.
#  #
#  def self.[](tag_class : Class)
#    @@register[tag_class]
#  end

#  #
#  #
#  #
#  def self.[]=(tag : String, tag_class : Class)
#    @@register[tag] = tag_class
#  end

#  Tag["tag:yaml.org,2002:str"] = String
#  Tag["tag:yaml.org,2002:seq"] = Array
#  Tag["tag:yaml.org,2002:map"] = Hash

end

#def Nil.yaml_serialize()
#  nil
#end

#def String.yaml_serialize(value : String)
#  value
#end

