module FilteredColumn
  module Filters
    class MacroFilter < Base
      @@macros = nil
      #TODO: Backreferences
      @@patterns = [
        /<(filter|macro):([_a-zA-Z0-9]+)([^>]*)\/>/,
        /<(filter|macro):([_a-zA-Z0-9]+)([^>]*)>(.*?)<\/(filter|macro):([_a-zA-Z0-9]+)>/m
        ]
      cattr_accessor :macros, :patterns
      
      class << self        
        def filter(text, options = {})
          patterns.each do |pattern|
            text.gsub!(pattern) do |match|
              macros[$2].filter(hash_from_attributes($3), ($4 || ''), text) if macros.keys.include?($2)
            end
          end
          text
        end
      
        protected
          def hash_from_attributes(string)
            attributes = {}
            string.gsub(/([^ =]+="[^"]*")/) do |match|
              key, value = match.split(/=/, 2)
              attributes[key] = value.gsub(/"/, '')
            end
          
            attributes.symbolize_keys!
          end
          
          def macros
            @@macros ||= FilteredColumn.default_macros.inject({}) do |macros, macro_name|
              klass = FilteredColumn::Filters::Macros.const_get(macro_name.to_s.camelize) rescue nil
              macros[macro_name] = klass unless klass.nil?
              macros
            end.stringify_keys
          end
      end
    end
  end
end