##
# A tag register is used to track class to tag associations.
#
class YAML::Tag::Register

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
  #
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
      list << tag if tag_class == key
    end
    list
  end

end
