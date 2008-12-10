require File.dirname(__FILE__) + '/../../spec_helper'

describe Admin::ArticlesController do
  controller_name "admin/articles"
  integrate_views

  it "should route /admin/articles/attach and friends correctly" do
    params = { :controller => "admin/articles", :action => "attach",
               :id => '1', :version => "2" }
    params_from(:post, "/admin/articles/attach/1/2").should == params
    params = { :controller => "admin/articles", :action => "detach",
               :id => '1', :version => "2" }
    params_from(:post, "/admin/articles/detach/1/2").should == params
  end
end
