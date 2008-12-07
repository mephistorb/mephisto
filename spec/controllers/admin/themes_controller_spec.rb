require File.dirname(__FILE__) + '/../../spec_helper'

describe Admin::ThemesController do
  controller_name "admin/themes"
  integrate_views

  it "should route /admin/themes/change_to/simpla to the change_to action" do
    params = { :controller => "admin/themes", :action => "change_to", :id => "simpla" }
    path = "/admin/themes/change_to/simpla"
    params_from(:post, path).should == params
    route_for(params).should == path
  end
    
end
