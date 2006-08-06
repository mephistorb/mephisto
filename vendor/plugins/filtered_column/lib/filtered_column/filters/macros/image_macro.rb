module FilteredColumn
  module Filters
    module Macros
      class ImageMacro
        include Reloadable
        def self.filter(attributes, inner_text = '', text = '')
          %(#{attributes[:file]})
        end
      end
    end
  end
end