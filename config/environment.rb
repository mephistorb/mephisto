# Be sure to restart your web server when you modify this file.

# Uncomment below to force Rails into production mode when 
# you don't control web/app server and can't set it the proper way
# ENV['RAILS_ENV'] ||= 'production'

#require 'rubygems'
#require 'ruby-debug'
#Debugger.start

# Mephisto now requires Rails 2.2
RAILS_GEM_VERSION = '2.2.2' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')
require File.join(File.dirname(__FILE__), '../vendor/plugins/engines/boot')
require File.join(File.dirname(__FILE__), '../lib/mephisto/plugin')

# Don't load the application when running rake db:* tasks, because doing so
# will try to access database tables before they exist.  See
# http://rails.lighthouseapp.com/projects/8994/tickets/63, which allegedly
# fixes this problem.  Here's where I got the idea:
# http://justbarebones.blogspot.com/2008/05/rails-202-restful-authentication-and.html
def safe_to_load_application?
  File.basename($0) != "rake" || !ARGV.any? {|a| a =~ /^(db|gems):/ }
end

# Make sure we a site-specific secret key file.
unless File.exists?(File.join(File.dirname(__FILE__),
                              'initializers/session_store.rb'))
  raise <<EOD
You need to run 'rake config/initializers/session_store.rb' to create a
secret key for encrypting session cookies.
EOD
end

Rails::Initializer.run do |config|
  # Settings in config/environments/* take precedence those specified here
  
  # Skip frameworks you're not going to use
  config.frameworks -= [ :active_resource ]

  config.load_paths += %W( #{RAILS_ROOT}/app/cachers #{RAILS_ROOT}/app/drops #{RAILS_ROOT}/app/filters )

  # This gem is a lightly-patched, in-tree version of rubypants.  The
  # upstream gem was last released in 2004, and needs to be repackaged
  # before we can treat it like a normal gem.
  config.load_paths += %W( #{RAILS_ROOT}/vendor/rubypants-0.2.0/lib )
  
  # NFI why this is here.  find and eradicate the bug.
  config.load_paths += %W( #{RAILS_ROOT}/vendor/rails/actionwebservice/lib )

  # Force all environments to use the same logger level 
  # (by default production uses :info, the others :debug)
  # config.log_level = :debug

  # Make Active Record use UTC-base instead of local time
  config.active_record.default_timezone = :utc
  
  # Use Active Record's schema dumper instead of SQL when creating the test database
  # (enables use of different database adapters for development and test environments)
  config.active_record.schema_format = :ruby

  # Register our observers.
  if safe_to_load_application?
    config.active_record.observers = [:article_observer, :comment_observer]
  end

  # Allow table tags in untrusted HTML, but block img tags to prevent
  # SRC attributes from being used in CSRF attacks.
  config.action_view.sanitized_allowed_tags = ['table', 'tr', 'td']
  config.after_initialize do
    ActionView::Base.sanitized_allowed_tags.delete 'img'
    ActionView::Base.sanitized_allowed_attributes.delete 'src'
  end

  # We're slowly moving the contents of vendor and vender/plugins into
  # vendor/gems by adding config.gem declarations.
  config.gem 'RedCloth', :version => '3.0.4', :lib => 'redcloth'
  config.gem 'BlueCloth', :version => '>= 1.0.0', :lib => 'bluecloth'
  config.gem 'rubyzip', :version => '>= 0.9.1', :lib => 'zip/zipfilesystem'
  config.gem 'liquid', :version => '>= 1.9.0'
  config.gem 'will_paginate', :version => '>= 2.2.2'
  config.gem 'mocha', :version => '>= 0.9.3'
  config.gem 'coderay', :version => '>= 0.8.260'
  config.gem 'tzinfo', :version => '>= 0.3.12'
  config.gem 'emk-safe_erb', :version => '>= 0.1.2', :lib => 'safe_erb',
             :source => 'http://gems.github.com'
end

# Don't update this file, make custom tweaks in config/initializers/custom.rb, 
# or create your own file in config/initializers
