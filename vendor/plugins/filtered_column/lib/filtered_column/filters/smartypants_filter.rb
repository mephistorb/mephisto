module FilteredColumn
  module Filters
    class SmartypantsFilter
      def self.filter(text)
        RubyPants.new(text).to_html if Object.const_defined?("RubyPants")
      end
    end
  end
end