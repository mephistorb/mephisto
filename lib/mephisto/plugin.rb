module Mephisto
  # This module assists with general Mephisto plugins.
  class Plugin < ActiveRecord::Base
    set_table_name 'mephisto_plugins'
    serialize :options, Hash
  
    @@custom_routes = []
    @@view_paths    = {}
    @@tabs          = []
    @@admin_tabs    = []
    cattr_reader :custom_routes, :view_paths, :tabs, :admin_tabs
  
    class << self
      expiring_attr_reader :plugin_name, 'name.demodulize.underscore'
      expiring_attr_reader :plugin_path, "RAILS_PATH + 'vendor/plugins' + ('mephisto_' + plugin_name)"
  
      plugin_property_source = %w(author version homepage notes).collect! do |property|
        <<-END
          def #{property}(value = nil)
            @#{property} = value if value
            @#{property}
          end
        END
      end
      eval plugin_property_source * "\n"
  
      # Finds or initializes a new plugin record from the database by the plugin name
      def find_or_initialize
        find_or_initialize_by_name(plugin_name)
      end
  
      #
      # Matches key to sub classes of Mephisto::Plugin in the namespace Mephisto::Plugins.
      # In other words, your plugin needs to subclass the former and be within the latter.
      #
      def find_class(key)
        klass_name = key.to_s.camelize
        klass = Mephisto::Plugins.const_get klass_name
        if klass < Mephisto::Plugin
          klass
        else
          raise NameError, "Plugin class must subclass Mephisto::Plugin"
        end
      end
      
      def [](key)
        find_class(key).find_or_initialize
      end
      
      def load(plugin_list)
        returning find_all_by_name(plugin_list).index_by(&:name) do |plugins|
          plugin_list.each do |name|
            if plugin_class = plugins[name].nil? && self[name]
              plugins[name] ||= plugin_class.new(:name => name)
            end
          end
        end
      end
      
      def default_options
        @default_options ||= {}
      end
      
      def option(property, default, field_type = :text_field)
        class_eval <<-END, __FILE__, __LINE__
            def #{property}
              write_attribute(:options, {}) if read_attribute(:options).nil?
              options[#{property.inspect}].blank? ? #{default.inspect} : options[#{property.inspect}]
            end
            
            def #{property}=(value)
              write_attribute(:options, {}) if read_attribute(:options).nil?
              options[#{property.inspect}] = value
            end
          END
        default_options[property] = field_type
      end
  
      # Installs the plugin's tables using the schema file in lib/#{plugin_name}/schema.rb
      #
      #   script/runner -e production 'Mephisto::Plugins::Foo.install'
      #   => installs the mephisto_foo plugin.
      #
      def install
        self::Schema.install
      end
      
      # Uninstalls the plugin's tables using the schema file in lib/#{plugin_name}/schema.rb
      def uninstall
        self::Schema.uninstall
      end
      
      # Adds a custom route to Mephisto from a plugin.  These routes are created in the order they are added.  
      # They will be the last routes before the Mephisto Dispatcher catch-all route.
      def add_route(*args)
        custom_routes << args
      end
  
      # Keeps track of custom adminstration tabs.  Each item is an array of arguments to be passed to link_to.
      #
      #   module Mephisto
      #     module Plugins
      #       class Foo < Mephisto::Plugin
      #         add_tab 'Foo', :controller => 'foo'
      #       end
      #     end
      #   end
      def add_tab(*args)
        tabs << args
      end
  
      # Keeps track of custom adminstration tabs for ADMIN users only.  Each item is an array of arguments to be passed to link_to.
      #
      #   module Mephisto
      #     module Plugins
      #       class Foo < Mephisto::Plugin
      #         add_admin_tab 'Foo', :controller => 'foo'
      #       end
      #     end
      #   end
      def add_admin_tab(*args)
        admin_tabs << args
      end
  
      # Sets up a custom public controller for this plugin.  It adds the plugin's lib directory to the controller paths directory and
      # saves the view path.  Call this from your plugin's init.rb file.
      #
      #   # #underscore will be called on the title parameter, so the 4th parameter 'foo' is unnecessary here.
      #   module Mephisto
      #     module Plugins
      #       class Foo < Mephisto::Plugin
      #         public_controller 'Foo', 'foo'
      #       end
      #     end
      #   end
      #
      # Once set, create your controller in #{YOUR_PLUGIN}/lib/foo_controller.rb.
      #
      #   class FooController < ApplicationController
      #     self.template_root = Mephisto::Plugin.view_paths[:foo]
      #     ...
      #   end
      #
      # Your views will then be stored in #{YOUR_PLUGIN}/views/foo/*.rhtml.
      def public_controller(title, name = nil)
        returning((name || title.underscore).to_sym) do |controller_name|
          view_paths[controller_name] = (plugin_path + 'views').to_s
        end
      end
  
      # Sets up a custom admin controller.  Mephisto::Plugin.public_controller is used for the basic setup.  This also automatically
      # adds a tab for you, and symlinks Mephisto's core app/views/layouts path.  Like Mephisto::Plugin.public_controller, this should be
      # called from your plugin's init.rb file.
      #
      #   module Mephisto
      #     module Plugins
      #       class Foo < Mephisto::Plugin
      #         admin_controller 'Foo', 'foo'
      #       end
      #     end
      #   end
      #
      #   module Admin
      #     class FooController < Admin::BaseController
      #       self.template_root = Mephisto::Plugin.view_paths[:foo]
      #       ...
      #     end
      #   end
      #
      # Your views will then be stored in #{YOUR_PLUGIN}/views/admin/foo/*.rhtml.
      def admin_controller(title, name = nil, options = {})
        returning public_controller(title, name) do |controller_name|
          add_tab title, {:controller => "admin/#{controller_name}"}.update(options)
          unless File.exists?(File.join(view_paths[controller_name], 'layouts'))
            FileUtils.mkdir_p view_paths[controller_name]
            FileUtils.symlink(RAILS_PATH + 'app/views/layouts', File.join(view_paths[controller_name], 'layouts'))
          end
        end
      end
    end
  
    plugin_property_source = %w(author version homepage notes plugin_name plugin_path default_options).collect! do |property|
      "def #{property}() self.class.#{property} end"
    end
    eval plugin_property_source * "\n"
  end
end