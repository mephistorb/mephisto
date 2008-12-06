require File.dirname(__FILE__) + '/../spec_helper'

describe "Admin::DesignController routing" do
  controller_name "admin/design"
  it "should call the index action at /admin/design" do
    params = { :controller => "admin/design", :action => "index" }
    params_from(:get, "/admin/design").should == params
  end
end