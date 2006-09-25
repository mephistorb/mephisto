require File.dirname(__FILE__) + '/../../test_helper'
require 'admin/themes_controller'

# Re-raise errors caught by the controller.
class Admin::ThemesController; def rescue_action(e) raise e end; end

class Admin::ThemesControllerTest < Test::Unit::TestCase
  fixtures :users, :sections, :sites, :memberships
  def setup
    @controller = Admin::ThemesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    login_as :quentin
    prepare_theme_fixtures
  end

  def test_should_allow_site_admin
    login_as :arthur
    get :index
    assert_response :success
  end

  def test_should_not_allow_site_member
    login_as :arthur, :hostess
    get :index
    assert_redirected_to :controller => 'account', :action => 'login'
  end
  
  def test_should_show_import_form
    get :import
    assert_response :success
    assert_template 'import'
  end
  
  def test_should_show_import_form_on_bad_post
    post :import
    assert_response :success
    assert_template 'import'
    assert_select "div#flash-errors", /\w+/
  end

  def test_should_show_import_form_on_bad_upload_content_type
    post :import, :theme => fixture_file_upload('themes/site-1/hemingway.zip', 'foo/bar')
    assert_response :success
    assert_template 'import'
    assert_select "div#flash-errors", /\w+/
  end

  def test_should_import_theme
    post :import, :theme => fixture_file_upload('themes/site-1/hemingway.zip', 'application/zip')
    assert_redirected_to :action => 'index'
    assert_equal %w(current empty encytemedia hemingway), sites(:first).themes.collect(&:name)
    assert_equal 'Hemingway', sites(:first).themes[:hemingway].title
  end
  
  def test_should_delete_theme
    delete :destroy, :id => 'encytemedia'
    assert_equal 2, assigns(:index)
    assert_redirected_to :action => 'index'
    assert_match /deleted/, flash[:notice]
    assert_equal %w(current empty), sites(:first).themes.collect(&:name)
  end
  
  def test_should_not_delete_current_theme
    delete :destroy, :id => 'current'
    assert_redirected_to :action => 'index'
    assert_match /current/, flash[:error]
    assert_equal %w(current empty encytemedia), sites(:first).themes.collect(&:name)
  end
  
  def test_should_delete_theme_with_ajax
    xhr :delete, :destroy, :id => 'empty'
    assert_equal 1, assigns(:index)
    assert_response :success
    assert_match /deleted/, flash[:notice]
    assert_equal %w(current encytemedia), sites(:first).themes.collect(&:name)
  end
  
  def test_should_not_delete_current_theme_with_ajax
    xhr :delete, :destroy, :id => 'current'
    assert_response :success
    assert_match /current/, flash[:error]
    assert_equal %w(current empty encytemedia), sites(:first).themes.collect(&:name)
  end
end
