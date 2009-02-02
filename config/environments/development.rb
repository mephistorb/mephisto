# Settings specified here will take precedence over those in config/environment.rb

# In the development environment your application's code is reloaded on
# every request.  This slows down response time but is perfect for development
# since you don't have to restart the webserver when you make code changes.
config.cache_classes     = false

# Log error messages when you accidentally call methods on nil.
config.whiny_nils        = true

# Show full error reports and disable caching
config.action_controller.consider_all_requests_local = true
config.action_controller.perform_caching             = false

# Don't care if the mailer can't send
config.action_mailer.raise_delivery_errors = false

# These libraries are needed for our tests and specs.  We include them
# here, and not in test.rb, because (1) it's easier to run 'rake
# gems:install' from the development environment than from the test
# environment, and (2) anyone doing Mephisto development should _really_ be
# running the tests anyway.
config.gem 'ruby-debug'
config.gem 'faker', :version => '>= 0.3.1'
config.gem 'notahat-machinist', :version => '>= 0.1.2', :lib => 'machinist',
                                :source => 'http://gems.github.com'
config.gem 'nokogiri', :version => '>= 1.1.0' # Used by webrat.
config.gem 'brynary-webrat', :version => '>= 0.3.2.2', :lib => 'webrat',
                             :source => 'http://gems.github.com'
