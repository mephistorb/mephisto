require File.dirname(__FILE__) + '/../../spec_helper'

describe Admin::DesignController do
  controller_name "admin/design"
  integrate_views

  it "should route /admin/design to the index action" do
    params = { :controller => "admin/design", :action => "index" }
    params_from(:get, "/admin/design").should == params
    route_for(params).should == "/admin/design"
  end
end
