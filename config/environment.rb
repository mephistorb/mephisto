# Be sure to restart your web server when you modify this file.

# Uncomment below to force Rails into production mode when 
# you don't control web/app server and can't set it the proper way
# ENV['RAILS_ENV'] ||= 'production'

#require 'rubygems'
#require 'ruby-debug'
#Debugger.start

# Mephisto only works with Rails 2.0 right now, so lock it to 2.0.5, which
# has the latest set of security fixes for 2.0.
RAILS_GEM_VERSION = '2.2.2' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')
require File.join(File.dirname(__FILE__), '../vendor/plugins/engines/boot')
require File.join(File.dirname(__FILE__), '../lib/mephisto/plugin')

# requires vendor-loaded redcloth
require 'RedCloth-3.0.4/lib/redcloth' unless Object.const_defined?(:RedCloth)

Rails::Initializer.run do |config|
  # Settings in config/environments/* take precedence those specified here
  
  # Skip frameworks you're not going to use
  config.frameworks -= [ :active_resource ]

  config.load_paths += %W( #{RAILS_ROOT}/app/cachers #{RAILS_ROOT}/app/drops #{RAILS_ROOT}/app/filters )
  
  # NFI why this is here.  find and eradicate the bug.
  config.load_paths += %W( #{RAILS_ROOT}/vendor/rails/actionwebservice/lib )

  # Force all environments to use the same logger level 
  # (by default production uses :info, the others :debug)
  # config.log_level = :debug

  # Use the database for sessions instead of the file system
  # (create the session table with 'rake create_sessions_table')
  # config.action_controller.session_store = :active_record_store
  config.action_controller.session = { :session_key => "_mephisto_session", :secret => "bd088a0f5b476fe5a2c02653a93ed14a95a8396829ce4e726ee77553ab6438a98d0f3e6d80fc6b120370ba047f28e09f71543ae5f842365e5070e7db51fb2cb9" }

  # Make Active Record use UTC-base instead of local time
  config.active_record.default_timezone = :utc
  
  # Use Active Record's schema dumper instead of SQL when creating the test database
  # (enables use of different database adapters for development and test environments)
  config.active_record.schema_format = :ruby
end

# Don't update this file, make custom tweaks in config/initializers/custom.rb, 
# or create your own file in config/initializers
