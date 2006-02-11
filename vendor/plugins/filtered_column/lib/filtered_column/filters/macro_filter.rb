module FilteredColumn
  module Filters
    class MacroFilter
      @@macros = nil
      #TODO: Backreferences
      @@patterns = [
        /<filter:([_a-zA-Z0-9]+)[^>]*\/>/,
        /<filter:([_a-zA-Z0-9]+)([^>]*)>(.*?)<\/filter:([_a-zA-Z0-9]+)>/m
        ]
      cattr_accessor :macros, :patterns
      
      class << self
        def filter(text, options = {})
          patterns.inject(text) do |txt, pattern|
            txt.gsub(pattern) do |match|
              macro_classes[$1].filter(hash_from_attributes(match)) if macros.keys.include?($1)
            end
          end
        end
      
        protected
        def hash_from_attributes(string)
          attributes = {}
          string.gsub(/([^ =]+="[^"]*")/) do |match|
            attributes[key] = match.split(/=/, 2).last.gsub(/"/, '')
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