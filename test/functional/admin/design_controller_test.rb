require File.dirname(__FILE__) + '/../../test_helper'
require 'admin/design_controller'

# Re-raise errors caught by the controller.
class Admin::DesignController; def rescue_action(e) raise e end; end

class Admin::DesignControllerTest < Test::Unit::TestCase
  fixtures :users, :sections, :sites

  def setup
    prepare_theme_fixtures
    @controller = Admin::DesignController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    login_as :quentin
  end

  def test_should_show_all_templates
    get :index
    assert_tag :tag => 'form', :attributes => { :action => '/admin/resources/upload' }
  end

  def test_should_create_template
    post :create, :data => 'this is liquid', :filename => 'my_little_pony'
    assert sites(:first).templates['my_little_pony'].file?
    assert_equal 'this is liquid', sites(:first).templates['my_little_pony'].read
    assert_redirected_to :controller => 'admin/templates', :action => 'edit', :filename => 'my_little_pony.liquid'
  end

  def test_should_create_css
    post :create, :data => 'body {}', :filename => 'styles.css'
    assert sites(:first).resources['styles.css'].file?
    assert_equal 'body {}', sites(:first).resources['styles.css'].read
    assert_redirected_to :controller => 'admin/resources', :action => 'edit', :filename => 'styles.css'
  end

  def test_should_show_form_on_invalid_creation_attempt
    post :create, :data => 'body {}'
    assert_template 'index'
    assert_response :success
  end
end
