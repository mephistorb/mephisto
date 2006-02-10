class AbstractFilter
  def self.filter(text)
    raise NotImplementedError, "You must define filter in a Subclass"
  end
end