module FilteredColumn
  module Filters
    module Macros
      
      class Code
        
        def self.filter(attributes, inner_text = '', text = '')
          begin
            CodeRay.scan(inner_text, attributes[:lang].to_sym).div(
              :line_numbers => :table, :css => :class
            )
          rescue
            unless attributes[:lang].blank?
              logger.warn "CodeRay Error: #{$!.message}"
              logger.debug $!.backtrace.join("\n")
            end
            "<pre><code>#{inner_text}</code></pre>"
          end
        end
        
      end
    
    end
  end
end