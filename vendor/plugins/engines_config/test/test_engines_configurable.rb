require File.expand_path(File.dirname(__FILE__) + '/test_helper.rb')

class EnginesConfigurableTest < Test::Unit::TestCase
  def teardown
    Engines::Plugin::Config.destroy_all
    plugin_alpha.instance_variable_set(:@config, nil)
  end
  
  def test_should_load_test_plugin
    assert_nothing_raised { plugin_alpha }
  end
  
  def test_should_allow_to_define_option_within_plugin_init_rb
    assert plugin_alpha.respond_to?(:an_option)
  end  
  
  def test_should_use_option_default_value
    assert_equal 'a default', plugin_alpha.an_option
  end
  
  def test_should_save_option_to_active_record_store
    plugin_alpha.another_option = 'a value'
    plugin_alpha.save!
    assert_equal 'a value', Engines::Plugin::Config.find_by_name('plugin_alpha').options[:another_option]
  end
  
  def test_should_read_option_from_active_record_store
    plugin_alpha.another_option = 'a value'
    plugin_alpha.save!
    assert_equal 'a value', plugin_alpha.another_option
  end
  
  private
  
  def plugin_alpha
    Engines.plugins['plugin_alpha']
  end
end
