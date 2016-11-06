abstract class YAML::Recognizer

end

class YAML::DefaultRecognizer < YAML::Recognizer

  #
  # Implicit conversions
  #
  def construct("", value : String)
    case value
    when /^\d+$/
      value.to_u32
    when /^\d*[.]\d+$/
      value.to_f64
    else
      value
    end
  end

  def construct("tag:yaml.org,2002:str", value : String)
    value
  end

  def construct("tag:yaml.org,2002:map", value : Hash)
    value
  end

  def construct("tag:yaml.org,2002:seq", value : Array)
    value
  end

  def construct(tag : String, value : Nil)
    nil
  end

  def construct(tag : String, value : String)
    value
  end

end

