class TextileFilter < AbstractFilter
  def self.text(text)
    RedCloth.new(text).to_html if Object.const_defined?("RedCloth")
  end
end