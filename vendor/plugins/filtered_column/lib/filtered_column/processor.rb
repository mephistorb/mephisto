module FilteredColumn
  @@filters = {}
  @@macros  = {}
  mattr_reader :filters, :macros

  class Processor
    @@patterns = [
      /<(filter|macro|typo):([_a-zA-Z0-9]+)([^>]*)\/>/,
      /<(filter|macro|typo):([_a-zA-Z0-9]+)([^>]*)>(.*?)<\/(filter|macro):([_a-zA-Z0-9]+)>/m
      ].freeze

    class << self
      def process_filter(filter_name, text)
        return '' if text.blank?
        process_macros(text) if FilteredColumn.macros.any?
        filter_text filter_name, text
      end

      def filter_text(filter_name, text_to_filter)
        return text_to_filter if filter_name.blank?
        filter_class = FilteredColumn.filters[filter_name.to_sym]
        return text_to_filter if filter_class.nil?
        filter_class.filter text_to_filter
      end
      
      def process_macros(text_to_filter)
        #RAILS_DEFAULT_LOGGER.warn "PROCESSING MACROS: #{::FilteredColumn.macros.keys.inspect}"
        @@patterns.each do |pattern|
          text_to_filter.gsub!(pattern) do |match|
            #RAILS_DEFAULT_LOGGER.warn "our match: #{$2}"
            key = "#{$2}_macro".to_sym
            if !$2.blank? && FilteredColumn.macros.has_key?(key)
              #RAILS_DEFAULT_LOGGER.warn "It has the key!"
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