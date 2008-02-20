module Engines
  class Plugin
    module Configurable
      class Config < ActiveRecord::Base  
        set_table_name 'plugin_configs'
        serialize :options, Hash
    
        def after_initialize
          write_attribute(:options, {}) if read_attribute(:options).nil?
        end
      end

      def option(property, default, field_type = :text_field)
        instance_eval <<-END, __FILE__, __LINE__
          def #{property}
            config.options[#{property.inspect}] || #{default.inspect}
          end      
          def #{property}=(value)
            config.options[#{property.inspect}] = value
          end
        END
        default_options[property] = field_type
      end
  
      def options=(options)
        config.options = options
      end
  
      def default_options
        @default_options ||= {}
      end
      
      def save!
        config.save!        
      end
      
      def destroy
        config.destroy
        @config = nil
      end
      
      private
  
      def config
        @config ||= Config.find_or_initialize_by_name(conf_name)
      end
      
      # allow subclasses to hook in here
      def conf_name
        name
      end
    end
  end
end

Engines::Plugin.send :include, Engines::Plugin::Configurable
