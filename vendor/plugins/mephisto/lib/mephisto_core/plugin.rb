module Mephisto
  # This module assists with general Mephisto plugins.
  module Plugin
    extend self
    
    # Stores an array of custom routes.  Use #add_route to add new ones.
    expiring_attr_reader :custom_routes, :[]

    expiring_attr_reader :paths, '{}'

    # Installs the plugin's tables using the schema file in lib/#{plugin_name}/schema.rb
    #
    #   script/runner -e production 'Mephisto::Plugin.install :foo'
    #   => installs the mephisto_foo plugin.
    #
    def install(name)
      find_plugin_migration(name).install
    end
    
    # Uninstalls the plugin's tables using the schema file in lib/#{plugin_name}/schema.rb
    def uninstall(name)
      find_plugin_migration(name).uninstall
    end
    
    # Adds a custom route to Mephisto from a plugin.  These routes are created in the order they are added.  
    # They will be the last routes before the Mephisto Dispatcher catch-all route.
    def add_route(*args)
      custom_routes << args
    end

    # Sets up a custom controller for this plugin.  It adds the plugin's lib directory to the controller paths directory and
    # saves the view path.  Call this from your plugin's init.rb file.
    #
    #   # #underscore will be called on the title parameter, so the 4th parameter 'foo' is unnecessary here.
    #   Mephisto::Plugin.controller config, directory, 'Foo', 'foo'
    #
    # Once set, create your controller in #{YOUR_PLUGIN}/lib/foo_controller.rb.
    #
    #   class FooController < ApplicationController
    #     self.template_root = Mephisto::Plugin.paths[:foo]
    #     ...
    #   end
    #
    # Your views will then be stored in #{YOUR_PLUGIN}/views/foo/*.rhtml.
    def controller(config, directory, title, name = nil)
      returning((name || title.underscore).to_sym) do |controller_name|
        config.controller_paths << File.join(directory, 'lib')
        paths[controller_name] = File.join(directory, 'views')
      end
    end

    protected
      def find_plugin_migration(name)
        plugin_name = "mephisto_#{name}"
        require(RAILS_PATH + 'vendor/plugins' + plugin_name + 'lib' + plugin_name + 'schema')
        Mephisto.const_get(name.to_s.camelize)::Schema
      end
  end
end