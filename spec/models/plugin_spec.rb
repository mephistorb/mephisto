# cant get this working with autotest for some reason
# invoking the spec manually will work though

require File.join(File.dirname(__FILE__), '/../../config/boot')

Rails::Configuration.send(:define_method, :plugin_paths) do
  ["#{RAILS_ROOT}/vendor/plugins", "#{RAILS_ROOT}/vendor/plugins/engines_config/test/plugins"]
end

require File.dirname(__FILE__) + '/../spec_helper'

describe Mephisto::Plugin do
  # Temporarily disabled--see the comment on PluginWhammyJammy in
  # test_helper.rb for an explanation.

  #def plugin_alpha
  #  Engines.plugins['plugin_alpha']
  #end
  
  it "should filter plugin list and return mephisto plugins" do
    Engines.plugins.size.should > Mephisto.plugins.size
  end
  
  it "should be a mephisto plugin when its name starts with 'mephisto_'" do
    Mephisto.plugins.each {|p| p.name.should =~ /^mephisto_/ }
  end
  
  #it "should be configurable when at least one option is defined" do
  #  plugin_alpha.configurable?.should be_true
  #  Engines.plugins['engines'].configurable?.should be_false
  #end
  
  #it "should allow to add tabs" do
  #  Mephisto::Plugin.tabs.clear
  #  plugin_alpha.add_tab :something
  #  Mephisto::Plugin.tabs.first.first.should == :something
  #end
  
  #it "should allow to add admin tabs" do
  #  Mephisto::Plugin.admin_tabs.clear
  #  plugin_alpha.add_admin_tab :something
  #  Mephisto::Plugin.admin_tabs.first.first.should == :something
  #end
end
