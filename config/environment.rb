# Be sure to restart your web server when you modify this file.

# Uncomment below to force Rails into production mode when 
# you don't control web/app server and can't set it the proper way
# ENV['RAILS_ENV'] ||= 'production'

#require 'rubygems'
#require 'ruby-debug'
#Debugger.start

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

# requires vendor-loaded redcloth
require 'RedCloth-3.0.4/lib/redcloth' unless Object.const_defined?(:RedCloth)
Rails::Initializer.run do |config|
  # Settings in config/environments/* take precedence those specified here
  
  # Skip frameworks you're not going to use
  # config.frameworks -= [ :action_web_service ]

  config.load_paths += %W( #{RAILS_ROOT}/app/cachers #{RAILS_ROOT}/app/drops #{RAILS_ROOT}/app/filters )

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

# Set this if you're running under a sub directory
# ActionController::AbstractRequest.relative_url_root = '/blog'

# turn this on to get detailed cache sweeper logging in production mode
# Site.cache_sweeper_tracing = true

# Enable if you want to host multiple sites on this app
# Site.multi_sites_enabled = true

# shouldn't need to set the host, it's set automatically
UserMailer.default_url_options[:host] = 'localhost:3000'
UserMailer.mail_from = 'webmaster@localhost'

# OPTIONAL - Redirections
# Deny a route by immediately returning a 404
#
#   Mephisto::Routing.deny 'articles/trackback/*' # return 404
#
# Specify multiple denied routes:
# 
#   Mephisto::Routing.deny 'articles/trackback/*', 'monkey/foo/*'
#
# Redirect elsewhere.  You can fill in variables marked by ? or * with variable names beginning with :
#
# Redirect /old/foo to /new/foo and /old/foo/bar to /new/foo/bar
#
#   Mephisto::Routing.redirect 'old/*' => 'new/$1'
#
# Redirect with a more specific set of variables
#
#   Mephisto::Routing.redirect 'article/?/?/?' => 'new/$2/$1/$3'

# Multiple redirections at a time
#
#   Mephisto::Routing.redirect \
#     'old/*' => 'new/$1',
#     'article/?/?/?' => 'new/$2/$1/$3'