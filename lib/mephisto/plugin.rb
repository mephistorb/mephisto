# needs to be loaded before or at beginning of plugin init stage because it
# allows to use add_tab and add_admin_tab from plugin init.rb

module Mephisto 
  def self.plugins
    @@plugins ||= Engines::Plugin::List.new(Engines.plugins.select{ |plugin| plugin.mephisto_plugin? })
  end
  
  module Plugin
    @@tabs       = []
    @@admin_tabs = []
    mattr_reader :tabs, :admin_tabs
    
    # delegate read access to about info
    %w(author homepage version notes).each do |property|
      module_eval "def #{property}; about['#{property}'] end", __FILE__, __LINE__
    end

    # Keeps track of custom adminstration tabs. Each item is an array of arguments to be passed to link_to.
    def add_tab(*args)
      args.push(:controller => args.first.to_s.downcase) if (args.size == 1)
      Mephisto::Plugin.tabs << args
    end

    # Keeps track of custom adminstration tabs for ADMIN users only.  Each item is an array of arguments to be passed to link_to.
    def add_admin_tab(*args)
      args.push(:controller => args.first.to_s.downcase) if (args.size == 1)
      Mephisto::Plugin.admin_tabs << args
    end
    
    def mephisto_plugin?
      name =~ /\Amephisto_(\w+)\z/
    end
    
    def configurable?
      not default_options.empty?
    end
    
    def mephisto_name
      name.sub /\Amephisto_/, ''
    end
    alias :conf_name :mephisto_name
  end
end

Engines::Plugin.send :include, Mephisto::Plugin

module Engines
  class Plugin < Rails::Plugin
    protected
      # override engine default list for Mephisto plugins
      def default_code_paths
        %w(app/controllers app/helpers app/models app/drops components lib)
      end
  end
end
