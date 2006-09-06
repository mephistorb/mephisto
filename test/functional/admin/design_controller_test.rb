require File.dirname(__FILE__) + '/../../test_helper'
require 'admin/design_controller'

# Re-raise errors caught by the controller.
class Admin::DesignController; def rescue_action(e) raise e end; end

class Admin::DesignControllerTest < Test::Unit::TestCase
  fixtures :users, :sections, :sites, :memberships

  def setup
    prepare_theme_fixtures
    @controller = Admin::DesignController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
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

  def test_should_show_all_templates
    login_as :quentin
    get :index
    assert_tag :tag => 'form', :attributes => { :action => '/admin/resources/upload' }
  end

  def test_should_create_template
    login_as :quentin
    post :create, :data => 'this is liquid', :filename => 'my_little_pony'
    assert sites(:first).templates['my_little_pony'].file?
    assert_equal 'this is liquid', sites(:first).templates['my_little_pony'].read
    assert_redirected_to :controller => 'admin/templates', :action => 'edit', :filename => 'my_little_pony.liquid'
  end

  def test_should_create_css
    login_as :quentin
    post :create, :data => 'body {}', :filename => 'styles.css'
    assert sites(:first).resources['styles.css'].file?
    assert_equal 'body {}', sites(:first).resources['styles.css'].read
    assert_redirected_to :controller => 'admin/resources', :action => 'edit', :filename => 'styles.css'
  end

  def test_should_show_form_on_invalid_creation_attempt
    login_as :quentin
    post :create, :data => 'body {}'
    assert_template 'index'
    assert_response :success
  end
end
