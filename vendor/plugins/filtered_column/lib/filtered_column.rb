module FilteredColumn
  @@filters = Hash.new
  mattr_accessor :filters

  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    
    def filtered_column(name, options = {})
      define_method(name) do
        return read_attribute(name)
      end
  
      define_method("#{name}=") do |value|
        filters = []
        value_cache = value
        active_filters = FilteredColumn::filters.keys
        RAILS_DEFAULT_LOGGER.info("SELF HERE: #{self}")
        
        if self.respond_to?("#{name}_html")
          if options[:only] 
            filters << options[:only]
          elsif options[:except]
            filters << active_filters.dup - options[:except]
          else
            filters << active_filters
          end
          filtered_text = FilteredColumn.process(filters, value)          
          write_attribute("#{name}_html", filtered_text)
        end
        write_attribute(name, value_cache)
      end
      
      define_method("#{name}_filtered") do
        html = get_attribute("#{name}_html") 
        return html unless html.nil?
      end
      
    end
    
  end
  
  private
  
  def self.process(filters, text_to_filter)
    filters.flatten.each do |filter|
      text_to_filter = FilteredColumn::filters[filter.to_sym].send(:filter, text_to_filter)
    end
    text_to_filter
  end
  
end