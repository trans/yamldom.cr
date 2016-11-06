##
# The tag register is used to track class to tag associations.
#
class YAML::Tag::Register

  # Sigh, Crytal won't let us use `Class` as an argument type.
  # So we are using a Proc that contains the class for now.
  @tags : Hash(String, ->)

  def initialize
    @tags = Hash(String, ->).new
  end

  #
  # Returns class associated with a given tag.
  #
  def [](key : String)
    @tags[key].call
  end

  #
  # Associate a YAML tag with a class.
  #
  def []=(tag : String, tag_class : Class)
    @tags[tag] = ->{ tag_class }
  end

  #
  # Is a given tag defined?
  #
  # TODO: Can a tag actually ever be nil (from LibYAML)?
  #
  def tag?(tag : String?)
    tag ? false : @tags.has_key?(tag)
  end

  #
  # Returns tags associated with a given class.
  #
  def tags_for(key : Class)
    list = Array(String)
    @tags.each do |tag, tag_class|
      list << tag if tag_class.call == key
    end
    list
  end

end
