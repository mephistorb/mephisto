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
    login_as :quentin
  end

  def test_should_show_edit_resource_form
    get :edit, :filename => 'style.css'
    assert_tag :tag => 'form'
    assert_tag :tag => 'textarea', :attributes => { :id => 'data' }
  end

  def test_should_require_resource_id
    get :edit
    assert_redirected_to :action => 'index'
    assert flash[:error]
    
    get :update
    assert_redirected_to :action => 'index'
    assert flash[:error]
  end

  def test_should_require_posted_resource
    get :update, :filename => 'style.css', :data => 'foo'
    assert_redirected_to :action => 'edit'
    assert flash[:error]
    
    post :update, :filename => 'style.css'
    assert_redirected_to :action => 'edit'
    assert flash[:error]
  end

  def test_should_save_resource
    post :update, :filename => 'style.css', :data => 'body {}\na {}'
    assert_response :success
    assert_equal "body {}\\na {}", sites(:first).resources['style.css'].read
  end

  def test_should_upload_resource
    post :upload, :resource => fixture_file_upload('/files/rails.png', 'image/png')
    assert_not_nil flash[:notice]
    assert_nil     flash[:error]
    assert_redirected_to :controller => 'admin/design', :action => 'index'
    assert sites(:first).resources['rails.png'].file?
  end

  def test_should_redirect_on_upload_get_request
    get :upload, :resource => 'foo'
    assert_nil     flash[:notice]
    assert_not_nil flash[:error]
    assert_redirected_to :controller => 'admin/design', :action => 'index'
  end

  def test_should_redirect_on_empty_upload
    post :upload, :resource => nil
    assert_nil     flash[:notice]
    assert_not_nil flash[:error]
    assert_redirected_to :controller => 'admin/design', :action => 'index'
  end

  def test_should_remove_file
    assert sites(:first).resources['rails-logo.png'].file?
    post :remove, :filename => 'rails-logo.png'
    assert_response :success
    assert !sites(:first).resources['rails-logo.png'].file?
  end
end
