require File.dirname(__FILE__) + '/../../test_helper'
require 'admin/sites_controller'

# Re-raise errors caught by the controller.
class Admin::SitesController; def rescue_action(e) raise e end; end

class Admin::SitesControllerTest < Test::Unit::TestCase
  fixtures :users, :sites
  def setup
    @controller = Admin::SitesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_allow_admin_of_sites
    login_as :quentin
    get :index
    assert_response :success
  end
  
  def test_should_restrict_admin_of_sites
    login_as :arthur
    get :index
    assert_redirected_to :controller => 'account', :action => 'login'
  end

  def test_should_allow_admin_to_view_site
    login_as :quentin
    get :show, :id => sites(:hostess).id.to_s
    assert_response :success
  end

  def test_should_create_site
    login_as :quentin
    assert_difference Site, :count do
      post :create, :site => { :host => 'example.com', :email => 'foo@example.com', :title => 'example', :subtitle => 'example site' }
      assert_redirected_to :action => 'index'
      assert flash[:notice]
    end
  end

  def test_should_show_error_while_creating_site
    login_as :quentin
    assert_no_difference Site, :count do
      post :create, :site => { :host => 'not a valid host' }
      assert_response :success
    end
  end

  def test_should_destroy_site
    login_as :quentin
    assert_difference Site, :count, -1 do
      post :destroy, :id => sites(:hostess).id.to_s
      assert_redirected_to :action => 'index'
    end
  end

end
