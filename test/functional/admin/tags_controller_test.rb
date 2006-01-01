require File.dirname(__FILE__) + '/../../test_helper'
require 'admin/tags_controller'

# Re-raise errors caught by the controller.
class Admin::TagsController; def rescue_action(e) raise e end; end

class Admin::TagsControllerTest < Test::Unit::TestCase
  fixtures :tags, :users

  def setup
    @controller = Admin::TagsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    login_as :quentin
  end

  def test_should_list_templates
    get :index
    assert_equal 2, assigns(:tags).length
  end

  def test_should_create_template
    assert_difference Tag, :count do
      post :create, :tag => { :name => 'foo' }
      assert_response :success
    end
  end

  def test_should_edit_name
    xhr :post, :set_tag_name, :id => tags(:home).id, :value => 'foo'
    tags(:home).reload
    assert_equal 'foo', tags(:home).name
  end

  def test_should_destroy_tag
    xhr :post, :destroy, :id => tags(:home).id
    assert_nil Tag.find_by_id(tags(:home).id)
  end

  #def test_should_require_ajax
  #  get :create, :id => tags(:home).id, :tag => { :name => 'gah' }
  #  assert_redirected_to :action => 'index'
  #  assert flash[:error]
  #
  #  post :create, :id => tags(:home).id, :tag => { :name => 'gah' }
  #  assert_redirected_to :action => 'index'
  #  assert flash[:error]
  #end
  #
  #def test_should_require_posted_template
  #  xhr :post, :update, :id => tags(:layout).id
  #  assert_equal '', @request.body
  #end
end
