module FilteredColumn
  module Filters
    module Macros      
      class ImageMacro
        include Reloadable        
        def self.filter(attributes, inner_text = "", text = "")
          RAILS_DEFAULT_LOGGER.info "ATTRIBUTES...... #{attributes}"
          %(#{attributes[:file]})
        end
      end
    end
  end
end