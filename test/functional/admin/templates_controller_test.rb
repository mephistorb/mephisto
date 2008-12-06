require File.dirname(__FILE__) + '/../../test_helper'

# Re-raise errors caught by the controller.
class Admin::TemplatesController; def rescue_action(e) raise e end; end

class Admin::TemplatesControllerTest < Test::Unit::TestCase
  fixtures :users, :sections, :sites, :memberships

  def setup
    prepare_theme_fixtures
    @controller = Admin::TemplatesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_allow_site_admin
    login_as :arthur
    get :edit, :filename => 'layout.liquid'
    assert_response :success
  end

  def test_should_not_allow_site_member
    login_as :arthur, :hostess
    get :edit, :filename => 'home.liquid'
    assert_redirected_to :controller => '/account', :action => 'login'
  end

  def test_should_show_edit_template_form
    login_as :quentin
    get :edit, :filename => 'layout.liquid'
    assert_tag :tag => 'form'
    assert_tag :tag => 'textarea', :attributes => { :id => 'data' }
  end

  def test_should_require_template_filename_on_edit
    login_as :quentin
    get :edit
    assert_redirected_to :action => 'index'
    assert flash[:error]
  end
  
  def test_should_require_template_filename_on_update
    login_as :quentin
    post :update
    assert_redirected_to :action => 'index'
    assert flash[:error]
  end

  def test_should_require_post_on_update
    login_as :quentin
    get :update, :filename => 'layout.liquid'
    # We used to redirect to 'edit' and set flash[:error] here, but this
    # error-checking is now handled by Admin::BaseController
    # #protect_action, which doesn't bother to set a flash.
    assert_redirected_to :action => 'index'
  end
  
  def test_should_require_posted_template
    login_as :quentin
    post :update, :filename => 'layout.liquid'
    assert_redirected_to :action => 'edit'
    assert flash[:error]
  end

  def test_should_save_template
    login_as :quentin
    post :update, :filename => 'layout.liquid', :data => 'foo'
    assert_response :success
    assert_equal 'foo', sites(:first).templates['layout'].read
  end

  def test_should_remove_custom_template
    login_as :quentin
    assert sites(:first).templates[:author].file?
    post :remove, :filename => 'author.liquid'
    assert_response :success
    assert !sites(:first).templates[:author].file?
  end

  def test_should_protect_system_template_from_removal
    login_as :quentin
    assert sites(:first).templates[:layout].file?
    post :remove, :filename => 'layout.liquid'
    assert_response :success
    assert sites(:first).templates[:layout].file?
  end
end
