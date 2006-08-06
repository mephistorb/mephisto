module FilteredColumn
  module Filters
    class MacroFilter < Base
      @@macros = nil
      #TODO: Backreferences
      @@patterns = [
        /<filter:([_a-zA-Z0-9]+)[^>]*\/>/,
        /<filter:([_a-zA-Z0-9]+)([^>]*)>(.*?)<\/filter:([_a-zA-Z0-9]+)>/m
        ]
      cattr_accessor :macros, :patterns
      
      class << self        
        def filter(text, options = {})
          patterns.each do |pattern|
          text.gsub!(pattern) do |match|
              macros["#{$1}_macro"].filter(hash_from_attributes(match), $3, text) if macros.keys.include?("#{$1}_macro")
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
              macros.merge macro_name => FilteredColumn::Filters::Macros.const_get(macro_name.to_s.camelize)
            end.stringify_keys
          end
      end
    end
  end
end