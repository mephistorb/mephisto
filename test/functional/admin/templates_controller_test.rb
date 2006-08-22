require File.dirname(__FILE__) + '/../../test_helper'
require 'admin/templates_controller'

# Re-raise errors caught by the controller.
class Admin::TemplatesController; def rescue_action(e) raise e end; end

class Admin::TemplatesControllerTest < Test::Unit::TestCase
  fixtures :users, :sections, :sites

  def setup
    prepare_theme_fixtures
    @controller = Admin::TemplatesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    login_as :quentin
  end

  def test_should_show_edit_template_form
    get :edit, :filename => 'layout.liquid'
    assert_tag :tag => 'form'
    assert_tag :tag => 'textarea', :attributes => { :id => 'data' }
  end

  def test_should_require_template_filename
    get :edit
    assert_redirected_to :action => 'index'
    assert flash[:error]
    
    get :update
    assert_redirected_to :action => 'index'
    assert flash[:error]
  end

  def test_should_require_posted_template
    get :update, :filename => 'layout.liquid'
    assert_redirected_to :action => 'edit'
    assert flash[:error]
    
    post :update, :filename => 'layout.liquid'
    assert_redirected_to :action => 'edit'
    assert flash[:error]
  end

  def test_should_save_template
    post :update, :filename => 'layout.liquid', :data => 'foo'
    assert_response :success
    assert_equal 'foo', sites(:first).templates['layout'].read
  end
end
