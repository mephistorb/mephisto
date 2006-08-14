module FilteredColumn
  module Mixin
    def self.included(base)
      base.extend(ActMethod)
    end
    
    module ActMethod
      # filtered_column :name, :title, :only => [ :textile_filter, :smartypants_filter ]
      def filtered_column(*names)
        unless included_modules.include?(InstanceMethods)
          send :include, InstanceMethods
          class_inheritable_accessor :filtered_attributes, :filtered_options
          before_save :process_filters
          serialize   :filters, Array
        end
        
        options = names.last.is_a?(Hash) ? names.pop : {}
        names.each do |name|
          (self.filtered_options    ||= {})[name] = options
          (self.filtered_attributes ||= []) << name
        end
      end

      module InstanceMethods
        def filters=(value)
          write_attribute :filters, [value].flatten.collect { |v| v.blank? ? nil : v.to_sym }.compact.uniq
        end

        protected
          def process_filters
            filtered_attributes.each do |attr_name|
              send "#{attr_name}_html=", FilteredColumn::Processor.process_filters(filters_for_attribute(attr_name), send(attr_name).to_s.dup)
            end
          end
          
          def filters_for_attribute(attr_name)
            filters   = self.filters
            filters ||= filtered_options[attr_name][:only]
            filters ||= (FilteredColumn.filters.keys - [filtered_options[attr_name][:except]].flatten || [])
          end
      end
    end
  end
end