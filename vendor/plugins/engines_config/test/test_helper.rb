ENV['RAILS_ENV'] = 'test'

require 'test/unit' 
require File.join(File.dirname(__FILE__), '../../../../config/boot')

Rails::Configuration.send(:define_method, :plugin_paths) do
  ["#{RAILS_ROOT}/vendor/plugins", "vendor/plugins/engines_config/test/plugins"]
end

require File.expand_path(File.join(File.dirname(__FILE__), '../../../../config/environment'))

Engines::Plugin::Config.set_table_name 'plugin_configs' 

config = { :adapter => "sqlite3", :dbfile => File.dirname(__FILE__) + "/db/engines_config_plugin.sqlite3.db" }
ActiveRecord::Base.logger = Logger.new(File.dirname(__FILE__) + "/log/debug.log")
ActiveRecord::Base.establish_connection(config)

unless ActiveRecord::Base.connection.tables.include?('plugin_configs')
  ActiveRecord::Schema.define(:version => 0) do
    create_table :plugin_configs, :force => true do |t|
      t.string "name"
      t.text   "options"
      t.string "type"
    end
  end
end