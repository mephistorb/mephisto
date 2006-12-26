module FilteredColumn
  module Filters
    class SmartypantsFilter < Base
      set_name "Markdown with Smarty Pants"
      def self.filter(text)
        if Object.const_defined?(:BlueCloth) && Object.const_defined?(:RubyPants)
          BlueCloth.new(RubyPants.new(text.gsub(%r{</?notextile>}, '')).to_html).to_html
        else
          text
        end
      end
    end
  end
end