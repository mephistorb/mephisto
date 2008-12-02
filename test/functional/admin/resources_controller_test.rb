require File.dirname(__FILE__) + '/../../test_helper'
require 'admin/resources_controller'

# Re-raise errors caught by the controller.
class Admin::ResourcesController; def rescue_action(e) raise e end; end

class Admin::ResourcesControllerTest < Test::Unit::TestCase
  fixtures :users, :sites, :memberships
  def setup
    prepare_theme_fixtures
    @controller = Admin::ResourcesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_allow_site_admin
    login_as :arthur
    get :edit, :filename => 'style.css'
    assert_response :success
  end

  def test_should_not_allow_site_member
    login_as :arthur, :hostess
    get :edit, :filename => 'home.liquid'
    assert_redirected_to :controller => 'account', :action => 'login'
  end

  def test_should_show_edit_resource_form
    login_as :quentin
    get :edit, :filename => 'style.css'
    assert_tag :tag => 'form'
    assert_tag :tag => 'textarea', :attributes => { :id => 'data' }
  end

  def test_should_require_resource_id
    login_as :quentin
    get :edit
    assert_redirected_to :action => 'index'
    assert flash[:error]
  end
  
  def test_should_require_resource_id_on_update
    login_as :quentin
    post :update
    assert_redirected_to :action => 'index'
    assert flash[:error]
  end

  def test_should_require_posted_resource
    login_as :quentin
    get :update, :filename => 'style.css', :data => 'foo'
    assert_redirected_to :action => 'index'
  end
  
  def test_should_require_posted_resource_on_update
    login_as :quentin
    post :update, :filename => 'style.css'
    assert_redirected_to :action => 'edit'
    assert flash[:error]
  end

  def test_should_save_resource
    login_as :quentin
    post :update, :filename => 'style.css', :data => 'body {}\na {}'
    assert_response :success
    assert_equal "body {}\\na {}", sites(:first).resources['style.css'].read
  end

  def test_should_upload_resource
    login_as :quentin
    post :upload, :resource => fixture_file_upload('/files/rails.png', 'image/png')
    assert_not_nil flash[:notice]
    assert_nil     flash[:error]
    assert_redirected_to :controller => 'admin/design', :action => 'index'
    assert sites(:first).resources['rails.png'].file?
  end

  def test_should_redirect_on_upload_get_request
    login_as :quentin
    get :upload, :resource => 'foo'
    assert_nil     flash[:notice]
    assert_not_nil flash[:error]
    assert_redirected_to :controller => 'admin/design', :action => 'index'
  end

  def test_should_redirect_on_empty_upload
    login_as :quentin
    post :upload, :resource => nil
    assert_nil     flash[:notice]
    assert_not_nil flash[:error]
    assert_redirected_to :controller => 'admin/design', :action => 'index'
  end

  def test_should_remove_file
    login_as :quentin
    assert sites(:first).resources['rails-logo.png'].file?
    post :remove, :filename => 'rails-logo.png'
    assert_response :success
    assert !sites(:first).resources['rails-logo.png'].file?
  end
end
