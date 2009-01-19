config.cache_classes = true
config.whiny_nils    = true
config.action_controller.consider_all_requests_local = true
config.action_controller.perform_caching             = true
config.action_controller.page_cache_directory        = File.join(RAILS_ROOT, 'tmp/cache')
config.action_mailer.delivery_method = :test

# Disable request forgery protection in test environment
config.action_controller.allow_forgery_protection    = false

 # These libraries are needed for our tests and specs.
config.gem 'faker', :version => '>= 0.3.1'
config.gem 'notahat-machinist', :version => '>= 0.1.2', :lib => 'machinist',
                                :source => 'http://gems.github.com'
config.gem 'nokogiri', :version => '>= 1.1.0' # Used by webrat.
config.gem 'brynary-webrat', :version => '>= 0.3.2.2', :lib => 'webrat',
                             :source => 'http://gems.github.com'

