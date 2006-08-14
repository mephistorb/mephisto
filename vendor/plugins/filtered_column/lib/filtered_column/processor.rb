module FilteredColumn
  @@filters = {}
  @@macros  = {}
  mattr_reader :filters, :macros

  class Processor
    @@patterns = [
      /<(filter|macro):([_a-zA-Z0-9]+)([^>]*)\/>/,
      /<(filter|macro):([_a-zA-Z0-9]+)([^>]*)>(.*?)<\/(filter|macro):([_a-zA-Z0-9]+)>/m
      ]

    class << self
      def process_filters(filters, text_to_filter)
        return '' if text_to_filter.blank?
        process_macros(text_to_filter) if FilteredColumn.macros.any?
        [filters].flatten.inject(text_to_filter) { |txt, filter_name| filter_text filter_name, txt }
      end

      def filter_text(filter_name, text_to_filter)
        puts filter_name if FilteredColumn.filters[filter_name.to_sym].nil?
        FilteredColumn.filters[filter_name.to_sym].filter text_to_filter
      end
      
      def process_macros(text_to_filter)
        @@patterns.each do |pattern|
          text_to_filter.gsub!(pattern) do |match|
            #puts "our match: #{$2}"
            #puts "macros array: #{macros.inspect}"
            key = "#{$2}_macro".to_sym
            if !$2.blank? && FilteredColumn.macros.has_key?(key)
              #puts "It has the key!"
              FilteredColumn.macros[key].filter(hash_from_attributes($3), $4.to_s) 
            end
          end
        end
        text_to_filter
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
    end
  end
end