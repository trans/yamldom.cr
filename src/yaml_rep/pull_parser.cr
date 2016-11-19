class YAML::PullParser

  def scalar_tag
    ptr = @event.data.scalar.tag
    ptr ? String.new(ptr) : nil
  end

  def sequence_tag
    ptr = @event.data.sequence_start.tag
    ptr ? String.new(ptr) : nil
  end

  def mapping_tag
    ptr = @event.data.mapping_start.tag
    ptr ? String.new(ptr) : nil
  end

  def scalar_style
    @event.data.scalar.style
  end

  def sequence_style
    @event.data.sequence_start.style
  end

  def mapping_style
    @event.data.mapping_start.style
  end

end
