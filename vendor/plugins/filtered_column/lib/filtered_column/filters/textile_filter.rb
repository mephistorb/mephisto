module FilteredColumn
  module Filters
    class TextileFilter
      def self.filter(text)
        Object.const_defined?("RedCloth") ? RedCloth.new(text).to_html : text
      end
    end
  end
end