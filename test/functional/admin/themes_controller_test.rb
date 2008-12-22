require File.dirname(__FILE__) + '/../../test_helper'

# Re-raise errors caught by the controller.
class Admin::ThemesController; def rescue_action(e) raise e end; end

class AdminThemesControllerTest < ActiveSupport::TestCase
  fixtures :users, :sections, :sites, :memberships
  
  def setup
    @controller = Admin::ThemesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    login_as :quentin
    prepare_theme_fixtures
  end

  test "should allow site admin" do
    login_as :arthur
    get :index
    assert_response :success
  end

  test "should not allow site member" do
    login_as :arthur, :hostess
    get :index
    assert_redirected_to :controller => '/account', :action => 'login'
  end
  
  test "should respond to show" do
    login_as :arthur
    xhr(:get, 'show', :id => 'encytemedia', :format => 'js')
    assert_response :success
  end

  test "should show import form" do
    get :import
    assert_response :success
    assert_template 'import'
  end
  
  test "should show import form on bad post" do
    post :import
    assert_response :success
    assert_template 'import'
    assert_select "div#flash-errors", /\w+/
  end

  test "should show import form on bad upload content type" do
    post :import, :theme => fixture_file_upload('themes/site-1/hemingway.zip', 'foo/bar')
    assert_response :success
    assert_template 'import'
    assert_select "div#flash-errors", /\w+/
  end

  test "should import theme" do
    post :import, :theme => fixture_file_upload('themes/site-1/hemingway.zip', 'application/zip')
    assert_redirected_to :action => 'index'
    assert_equal %w(current empty encytemedia hemingway), sites(:first).themes.collect(&:name)
    assert_equal 'Hemingway', sites(:first).themes[:hemingway].title
  end
  
  test "should delete theme" do
    delete :destroy, :id => 'encytemedia'
    assert_equal 2, assigns(:index)
    assert_redirected_to :action => 'index'
    assert_match /deleted/, flash[:notice]
    assert_equal %w(current empty), sites(:first).themes.collect(&:name)
  end
  
  test "should not delete current theme" do
    delete :destroy, :id => 'current'
    assert_redirected_to :action => 'index'
    assert_match /current/, flash[:error]
    assert_equal %w(current empty encytemedia), sites(:first).themes.collect(&:name)
  end
  
  test "should delete theme with ajax" do
    xhr :delete, :destroy, :id => 'empty'
    assert_equal 1, assigns(:index)
    assert_response :success
    assert_match /deleted/, flash[:notice]
    assert_equal %w(current encytemedia), sites(:first).themes.collect(&:name)
  end

  test "should change theme with a post" do
    post :change_to, :id => 'encytemedia'
    assert_equal 'encytemedia', sites(:first).reload.current_theme_path
    assert sites(:first).theme.path.exist?, "#{sites(:first).theme.path.to_s} does not exist"
    assert_equal 'encytemedia', sites(:first).theme.name
    assert_equal 'Encytemedia', sites(:first).theme.title
  end
  
  test "should not change theme with a get" do
    get :change_to, :id => 'encytemedia'
    assert_redirected_to :action => 'index'
    assert_not_equal 'encytemedia', sites(:first).reload.current_theme_path
    assert_not_equal 'encytemedia', sites(:first).theme.name
    assert_not_equal 'Encytemedia', sites(:first).theme.title
  end
  
end
