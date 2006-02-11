module FilteredColumn
  module Filters
    module Macros
      class ImageMacro
      def self.filter(attributes, inner_text = "", text = "")
        %(#{attributes[:file]})
      end
    end
  end
end