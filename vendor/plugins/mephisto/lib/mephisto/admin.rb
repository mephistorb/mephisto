module Mephisto
  # This module helps with the installation of plugins that need to interact with the admin portion of Mephisto.
  module Admin
    extend self

    # Keeps track of custom adminstration tabs.  Each item is an array of arguments to be passed to link_to.
    # 
    #   Mephisto::Admin.tabs << ['Foo', {:controller => 'foo'}]
    expiring_attr_reader :tabs,  :[]

    # Sets up a custom admin controller.  Mephisto::Plugin.controller is used for the basic setup.  This also automatically
    # adds a tab for you, and symlinks Mephisto's core app/views/layouts path.  Like Mephisto::Plugin.controller, this should be
    # called from your plugin's init.rb file.
    #
    #   Mephisto::Admin.controller config, directory, 'Foo'
    #
    #   module Admin
    #     class FooController < Admin::BaseController
    #       self.template_root = Mephisto::Plugin.paths[:foo]
    #       ...
    #     end
    #   end
    #
    # Your views will then be stored in #{YOUR_PLUGIN}/views/admin/foo/*.rhtml.
    def controller(config, directory, title, name = nil, options = {})
      returning Mephisto::Plugin.controller(config, directory, title, name) do |controller_name|
        Mephisto::Admin.tabs << [title, {:controller => "admin/#{controller_name}"}.merge(options)]
        unless File.exists?(File.join(Mephisto::Plugin.paths[controller_name], 'layouts'))
          FileUtils.mkdir_p Mephisto::Plugin.paths[controller_name]
          FileUtils.symlink(RAILS_PATH + 'app/views/layouts', File.join(Mephisto::Plugin.paths[controller_name], 'layouts'))
        end
      end
    end
  end
end