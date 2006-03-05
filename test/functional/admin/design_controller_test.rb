require File.dirname(__FILE__) + '/../../test_helper'
require 'admin/design_controller'

# Re-raise errors caught by the controller.
class Admin::DesignController; def rescue_action(e) raise e end; end

class Admin::DesignControllerTest < Test::Unit::TestCase
  fixtures :attachments, :db_files, :users, :sections
  def setup
    @controller = Admin::DesignController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    login_as :quentin
  end

  def test_should_show_all_templates
    get :index
    assert_equal 10, assigns(:templates).length
    assert assigns(:templates).include?(attachments(:layout))
    assert_tag :tag => 'form', :attributes => { :action => '/admin/resources/upload' }
  end

  def test_should_create_template
    assert_difference Template, :count do
      post :create, :resource => { :data => 'this is liquid', :filename => 'my_little_pony' }, :resource_type => 'template'
      t = Template.find :first, :order => 'id desc'
      assert_equal 'templates/my_little_pony', t.full_path
      assert_redirected_to :controller => 'admin/templates', :action => 'edit', :id => 'my_little_pony'
    end
  end

  #def test_should_create_template_and_not_sweep_caches
  #  set_controller_url :index
  #  create_cached_page_for sections(:home), section_url(:sections => [])
  #  assert_not_expire_page_caches section_url(:sections => []) do
  #    post :create, :resource => { :data => 'this is liquid', :filename => 'my_little_pony' }, :resource_type => 'template'
  #  end
  #end

  def test_should_create_css
    assert_difference Resource, :count do
      post :create, :resource => { :data => 'body {}', :filename => 'styles' }, :resource_type => 'CSS'
      r = Resource.find :first, :order => 'id desc'
      assert_equal 'stylesheets/styles.css', r.full_path
      assert_redirected_to :controller => 'admin/resources', :action => 'edit', :id => r.id
    end
  end

  def test_should_show_form_on_invalid_creation_attempt
    assert_no_difference Resource, :count do
      post :create, :resource => { :data => 'body {}' }, :resource_type => 'CSS'
      assert_template 'index'
      assert_response :success
    end
  end
end
