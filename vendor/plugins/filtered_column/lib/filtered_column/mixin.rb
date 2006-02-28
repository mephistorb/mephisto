module FilteredColumn
  @@filters          = {}
  @@default_filters  = []
  @@default_macros   = []
  @@constant_filters = []
  mattr_reader :filters, :default_filters, :default_macros, :constant_filters

  module Mixin
    def self.included(base)
      base.extend(ActMethod)
    end
    
    module ActMethod
      # filtered_column :name, :title, :only => [ :textile_filter, :smartypants_filter ]
      def filtered_column(*names)
        send :include, InstanceMethods
        extend(ClassMethods)
        class_inheritable_accessor :filtered_attributes, :filtered_options
        before_validation :process_filters
        serialize         :filters, Array
        
        options = names.last.is_a?(Hash) ? names.pop : {}
        names.each do |name|
          (self.filtered_options    ||= {})[name] = options
          (self.filtered_attributes ||= []) << name
        end
      end

      module InstanceMethods
        def filters=(value)
          write_attribute :filters, [value].flatten.collect(&:to_sym)
        end

        protected
        def process_filters
          filtered_attributes.each do |attr_name|
            send "#{attr_name}_html=", self.class.process_filters(filters_for_attribute(attr_name), send(attr_name))
          end
        end

        def filters_for_attribute(attr_name)
          filters   = self.filters
          filters ||= filtered_options[attr_name][:only]
          filters ||= FilteredColumn.default_filters - ([filtered_options[attr_name][:except]].flatten || [])
        end
      end

      module ClassMethods
        def process_filters(filters, text_to_filter)
          [filters].flatten.inject(text_to_filter) { |txt, filter_name| filter_text filter_name, txt }
        end

        def filter_text(filter_name, text_to_filter)
          (FilteredColumn.filters[filter_name.to_sym] ||= FilteredColumn::Filters.const_get(filter_name.to_s.camelize)).filter text_to_filter unless text_to_filter.blank?
        end
      end      
    end
  end
end