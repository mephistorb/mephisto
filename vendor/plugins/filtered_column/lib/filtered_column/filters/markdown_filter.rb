require 'bluecloth'
module FilteredColumn
  module Filters
    class MarkdownFilter
      def self.filter(text)
        BlueCloth.new(text.gsub(%r{</?notextile>}, '')).to_html if Object.const_defined?("BlueCloth")
      end
    end
  end
end