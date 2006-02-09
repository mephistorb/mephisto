require File.dirname(__FILE__) + '/../../test_helper'
require 'admin/categories_controller'

# Re-raise errors caught by the controller.
class Admin::CategoriesController; def rescue_action(e) raise e end; end

class Admin::CategoriesControllerTest < Test::Unit::TestCase
  fixtures :categories, :users

  def setup
    @controller = Admin::CategoriesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    login_as :quentin
  end

  def test_should_list_categories
    get :index
    assert_equal 1, assigns(:categories).length # the home category is shifted off
  end

  def test_should_create_category
    assert_difference Category, :count do
      post :create, :category => { :name => 'foo' }
      assert_response :success
    end
  end

  def test_should_edit_name
    xhr :post, :update, :id => categories(:home).id, :category => { :name => 'foo' }
    categories(:home).reload
    assert_equal 'foo', categories(:home).name
  end

  def test_should_destroy_category
    xhr :post, :destroy, :id => categories(:home).id
    assert_nil Category.find_by_id(categories(:home).id)
  end

  #def test_should_require_ajax
  #  get :create, :id => categories(:home).id, :category => { :name => 'gah' }
  #  assert_redirected_to :action => 'index'
  #  assert flash[:error]
  #
  #  post :create, :id => categories(:home).id, :category => { :name => 'gah' }
  #  assert_redirected_to :action => 'index'
  #  assert flash[:error]
  #end
  #
  #def test_should_require_posted_template
  #  xhr :post, :update, :id => categories(:layout).id
  #  assert_equal '', @request.body
  #end
end
