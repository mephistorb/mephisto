require File.expand_path(File.dirname(__FILE__) + '/test_helper.rb')

class PluginAboutInfoTest < Test::Unit::TestCase
  def test_should_read_about_info_from_about_yml
    assert_equal 'Sven Fuchs', Engines.plugins['plugin_alpha'].about['author']
  end
end
