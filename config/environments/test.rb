config.cache_classes = true
config.whiny_nils    = true
config.action_controller.consider_all_requests_local = true
config.action_controller.perform_caching             = true
config.action_controller.page_cache_directory        = File.join(RAILS_ROOT, 'tmp/cache')
config.action_mailer.delivery_method = :test

# Disable request forgery protection in test environment
config.action_controller.allow_forgery_protection    = false

