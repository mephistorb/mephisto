require File.expand_path(File.dirname(__FILE__) + '/../../../../test/test_helper.rb')
Test::Unit::TestCase.fixture_path = File.dirname(__FILE__) + '/fixtures'

module Mephisto
  module Plugins
    class PluginWhammyJammy < Mephisto::Plugin
      default_options :foo => 'one', :bar => 2, :baz => [3]
    end
    
    class FooBar < Mephisto::Plugin
    end
    
    class NonPlugin
    end
  end
end