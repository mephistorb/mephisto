ENV["RAILS_ENV"] = "test"

require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'spec'
require 'spec/rails'
require 'ruby-debug'
require 'machinist'
require File.join(File.dirname(__FILE__), 'blueprints')

Spec::Runner.configure do |config|
  config.use_transactional_fixtures = true
  config.use_instantiated_fixtures  = false
  config.before(:each) { Sham.reset }  # Reset machinist before each test.
end

Debugger.start
