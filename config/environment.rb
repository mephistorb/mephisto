# Be sure to restart your web server when you modify this file.

# Uncomment below to force Rails into production mode when 
# you don't control web/app server and can't set it the proper way
# ENV['RAILS_ENV'] ||= 'production'

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

# requires vendor-loaded redcloth
require 'RedCloth-3.0.4/lib/redcloth'
Rails::Initializer.run do |config|
  # Settings in config/environments/* take precedence those specified here
  
  # Skip frameworks you're not going to use
  # config.frameworks -= [ :action_web_service ]

  config.autoload_paths += %W( #{RAILS_ROOT}/app/cachers )

  # Force all environments to use the same logger level 
  # (by default production uses :info, the others :debug)
  # config.log_level = :debug

  # Use the database for sessions instead of the file system
  # (create the session table with 'rake create_sessions_table')
  config.action_controller.session_store = :active_record_store

  # Make Active Record use UTC-base instead of local time
  config.active_record.default_timezone = :utc
  
  # Use Active Record's schema dumper instead of SQL when creating the test database
  # (enables use of different database adapters for development and test environments)
  config.active_record.schema_format = :ruby
end

# Include your application configuration below
require 'mephisto_init'

# Set this if you're running on a root path
# ActionController::AbstractRequest.relative_url_root = '/blog'

# turn this on to get detailed cache sweeper logging in production mode
# Mephisto::SweeperMethods.cache_sweeper_tracing = true

# Enable if you want to host multiple sites on this app
# Site.multi_sites_enabled = true