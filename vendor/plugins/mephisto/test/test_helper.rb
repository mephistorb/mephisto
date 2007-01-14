require File.expand_path(File.dirname(__FILE__) + '/../../../../test/test_helper.rb')
Test::Unit::TestCase.fixture_path = File.dirname(__FILE__) + '/fixtures'

module MephistoPlugins
  class PluginWhammyJammy < MephistoPlugin
    option :foo, 'one'
    option :bar, 2
    option :baz, [3]
  end
  
  class FooBar < MephistoPlugin
  end
  
  class NonPlugin
  end
end