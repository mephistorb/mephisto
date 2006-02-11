require 'bluecloth'

class MarkdownFilter < AbstractFilter
  def self.filter(text)
    BlueCloth.new(text.gsub(%r{</?notextile>}, '')).to_html if Object.const_defined?("BlueCloth")
  end
end