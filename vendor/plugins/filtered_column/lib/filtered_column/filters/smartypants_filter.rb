module FilteredColumn
  module Filters
    class SmartypantsFilter
      def self.filter(text)
        Object.const_defined?("RubyPants") ? RubyPants.new(text).to_html : text
      end
    end
  end
end