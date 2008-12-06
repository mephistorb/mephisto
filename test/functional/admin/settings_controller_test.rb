require File.dirname(__FILE__) + '/../../test_helper'

# Re-raise errors caught by the controller.
class Admin::SettingsController; def rescue_action(e) raise e end; end

class Admin::SettingsControllerTest < Test::Unit::TestCase
  fixtures :sites, :users, :memberships
  def setup
    @controller = Admin::SettingsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_show_settings
    login_as :quentin
    get :index
    assert_tag 'input', :attributes => { :id => 'site_title', :value => sites(:first).title }
  end

  def test_should_update_settings
    login_as :quentin
    post :update, :site => { :title => 'foo' }
    assert_equal 'foo', sites(:first).reload.title
    assert_redirected_to :action => 'index'
  end

  def test_should_clear_layouts
    login_as :quentin
    post :update, :site => { :title => 'foo', :tag_layout => '-' }
    assert_nil sites(:first).tag_layout
  end

  def test_should_allow_site_admin
    login_as :arthur
    get :index
    assert_response :success
  end
  
  def test_should_not_allow_site_member
    login_as :arthur, :hostess
    get :index
    assert_redirected_to :controller => '/account', :action => 'login'
  end
end
