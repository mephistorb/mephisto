module FilteredColumn
  module Filters
    class TextileFilter
      def self.filter(text)
        RedCloth.new(text).to_html if Object.const_defined?("RedCloth")
      end
    end
  end
end