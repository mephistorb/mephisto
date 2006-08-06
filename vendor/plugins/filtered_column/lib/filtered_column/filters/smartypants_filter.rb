module FilteredColumn
  module Filters
    class SmartypantsFilter < Base
      set_name "Markdown with Smarty Pants"
      def self.filter(text)
        Object.const_defined?("RubyPants") ? RubyPants.new(text).to_html : text
      end
    end
  end
end