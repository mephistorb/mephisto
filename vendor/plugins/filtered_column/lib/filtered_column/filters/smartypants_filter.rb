class SmartypantsFilter < AbstractFilter
  def self.filter(text)
    RubyPants.new(text).to_html if Object.const_defined?("RubyPants")
  end
end