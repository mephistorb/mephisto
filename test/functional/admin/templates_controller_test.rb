require File.dirname(__FILE__) + '/../../test_helper'
require 'admin/templates_controller'

# Re-raise errors caught by the controller.
class Admin::TemplatesController; def rescue_action(e) raise e end; end

class Admin::TemplatesControllerTest < Test::Unit::TestCase
  fixtures :attachments, :db_files, :users, :cached_pages, :sections

  def setup
    @controller = Admin::TemplatesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    login_as :quentin
  end

  def test_should_show_edit_template_form
    get :edit, :id => attachments(:layout).filename
    assert_tag :tag => 'form'
    assert_tag :tag => 'textarea', :attributes => { :id => 'template_data' }
  end

  def test_should_require_template_id
    get :edit
    assert_redirected_to :action => 'index'
    assert flash[:error]
    
    get :update
    assert_redirected_to :action => 'index'
    assert flash[:error]
  end

  def test_should_require_posted_template
    get :update, :id => attachments(:layout).filename, :template => { :filename => 'foo' }
    assert_redirected_to :action => 'edit'
    assert flash[:error]
    
    post :update, :id => attachments(:layout).filename
    assert_redirected_to :action => 'edit'
    assert flash[:error]
  end

  def test_should_save_template
    post :update, :id => attachments(:layout).filename, :template => { :filename => 'foo' }
    assert_response :success
    attachments(:layout).reload
    assert_equal 'foo', attachments(:layout).filename
  end

  #def test_should_save_template_and_sweep_caches
  #  set_controller_url :index
  #  create_cached_page_for sections(:home), section_url(:sections => [])
  #  assert_expire_page_caches section_url(:sections => []) do
  #    post :update, :id => attachments(:layout).filename, :template => { :filename => 'foo' }
  #  end
  #end
end
