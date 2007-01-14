require File.expand_path(File.dirname(__FILE__) + '/test_helper')

class PluginTest < Test::Unit::TestCase
  fixtures :mephisto_plugins

  def test_should_create_plugin_name
    assert_equal 'plugin_whammy_jammy', Mephisto::Plugins::PluginWhammyJammy.plugin_name
  end
  
  def test_should_find_plugin_class_by_name
    assert_equal Mephisto::Plugins::PluginWhammyJammy, Mephisto::Plugin.find_class(:plugin_whammy_jammy)
  end
  
  def test_should_not_find_missing_class
    assert_raises NameError do
      Mephisto::Plugin[:blah]
    end
  end
  
  def test_should_not_find_a_non_model
    assert Mephisto::Plugins.const_defined?(:NonPlugin)
    assert_raises NameError do
      Mephisto::Plugin[:non_plugin]
    end
  end
  
  def test_plugin_option_defaults
    plugin = Mephisto::Plugins::PluginWhammyJammy.new
    assert_equal 'one', plugin.foo
    assert_equal 2,     plugin.bar
    assert_equal [3],   plugin.baz
  end
  
  def test_should_set_plugin_options
    plugin = Mephisto::Plugins::PluginWhammyJammy.new
    
    plugin.foo = 'two'
    plugin.bar = 3
    plugin.baz = [4]
    assert_equal 'two', plugin.foo
    assert_equal 3,     plugin.bar
    assert_equal [4],   plugin.baz
    
    plugin.foo = ''
    assert_equal 'one', plugin.foo
    
    plugin.bar = nil
    assert_equal 2,     plugin.bar
  end
  
  def test_should_get_and_set_plugin_properties
    properties = %w(desc author version homepage)
    properties.each do |property|
      assert_nil Mephisto::Plugins::PluginWhammyJammy.send(property)
      Mephisto::Plugins::PluginWhammyJammy.send(property, 'foo')
      assert_equal 'foo', Mephisto::Plugins::PluginWhammyJammy.send(property)
      assert_equal 'foo', Mephisto::Plugins::PluginWhammyJammy.new.send(property)
    end
  end
  
  def test_should_find_plugin
    assert_equal Mephisto::Plugins::PluginWhammyJammy.find(1), Mephisto::Plugin[:plugin_whammy_jammy]
  end
  
  def test_should_persist_options
    plugin = Mephisto::Plugin[:plugin_whammy_jammy]
    assert_equal 'one', plugin.foo
    plugin.foo = 'two'
    plugin.save!
    assert_equal 'two', plugin.reload.foo
  end
  
  def test_should_persist_options_on_new_plugin_record
    Mephisto::Plugins::PluginWhammyJammy.delete_all
    plugin = Mephisto::Plugin[:plugin_whammy_jammy]
    klass1 = plugin.class.name
    
    assert plugin.new_record?
    assert_equal 'one', plugin.foo
    plugin.save!
    assert plugin.reload.options.empty?

    plugin2 = Mephisto::Plugin[:plugin_whammy_jammy]
    assert_equal 'one', plugin2.foo   
    reloaded_klass = plugin2.class.name
    
    assert_equal klass1, reloaded_klass
    plugin.foo = 'two'
    plugin.save
    
    plugin2.reload

    assert_equal 'two', plugin2.foo
  end
  
  # def test_should_load_or_initialize_plugin_list
 #    plugins = Mephisto::Plugin.load(%w(plugin_whammy_jammy foo_bar baz))
 #    assert_equal 2, plugins.size
 #    assert plugins['foo_bar'].new_record?
 #  end
end