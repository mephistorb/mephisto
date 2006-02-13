require File.dirname(__FILE__) + '/../../test_helper'
require 'admin/resources_controller'

# Re-raise errors caught by the controller.
class Admin::ResourcesController; def rescue_action(e) raise e end; end

class Admin::ResourcesControllerTest < Test::Unit::TestCase
  fixtures :attachments, :db_files, :users
  def setup
    @controller = Admin::ResourcesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    login_as :quentin
  end

  def test_should_show_edit_resource_form
    get :edit, :id => attachments(:css).id
    assert_tag :tag => 'form'
    assert_tag :tag => 'textarea', :attributes => { :id => 'resource_data' }
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
    get :update, :id => attachments(:css).id, :resource => { :filename => 'foo' }
    assert_redirected_to :action => 'edit'
    assert flash[:error]
    
    post :update, :id => attachments(:css).filename
    assert_redirected_to :action => 'edit'
    assert flash[:error]
  end

  def test_should_save_resource
    post :update, :id => attachments(:css).id, :resource => { :filename => 'foo', :data => "body {}\na {}" }
    assert_response :success
    attachments(:css).reload
    assert_equal 'foo.css',       attachments(:css).filename
    assert_equal "body {}\na {}", attachments(:css).data
  end

  def test_should_upload_resource
    assert_attachment_created do
      post :upload, :resource => { :uploaded_data => file_upload }
    end
    
    assert_redirected_to :controller => 'admin/design', :action => 'index'
  end

  protected
  def file_upload(options = {})
    Technoweenie::FileUpload.new(options[:filename] || 'rails.png', options[:content_type] || 'image/png')
  end
end
