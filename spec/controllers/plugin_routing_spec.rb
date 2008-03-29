# cant get this working with autotest for some reason
# invoking the spec manually will work though

# require File.join(File.dirname(__FILE__), '/../../config/boot')
# 
# Rails::Configuration.send(:define_method, :plugin_paths) do
#   ["#{RAILS_ROOT}/vendor/plugins", "#{RAILS_ROOT}/vendor/plugins/engines_config/test/plugins"]
# end
# 
# require File.dirname(__FILE__) + '/../spec_helper'
# 
# describe "Mephisto::Plugin routing" do
#   controller_name 'mephisto'
# 
#   it "should work" do
#     route_for(:controller => "somethings", :action => "index").should == "/something"
#   end
# end