require File.dirname(__FILE__) + '/../../test_helper'
require 'admin/tags_controller'

# Re-raise errors caught by the controller.
class Admin::TagsController; def rescue_action(e) raise e end; end

class Admin::TagsControllerTest < Test::Unit::TestCase
  fixtures :tags

  def setup
    @controller = Admin::TagsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_should_list_templates
    get :index
    assert_equal 2, assigns(:tags).length
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
  #
  #def test_should_save_template
  #  post :update, :id => templates(:layout).id, :template => { :name => 'foo' }
  #  assert_redirected_to :action => 'edit'
  #  assert flash[:notice]
  #  templates(:layout).reload
  #  assert_equal 'foo', templates(:layout).name
  #end
end
