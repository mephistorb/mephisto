ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'spec'
require 'spec/rails'
require 'ruby-debug'
require 'model_stubbing/spec'
require File.join(File.dirname(__FILE__), 'model_stubs')

Spec::Runner.configure do |config|
  config.use_transactional_fixtures = true
  config.use_instantiated_fixtures  = false
end

Debugger.start