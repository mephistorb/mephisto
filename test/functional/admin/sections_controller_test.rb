require File.dirname(__FILE__) + '/../../test_helper'
require 'admin/sections_controller'

# Re-raise errors caught by the controller.
class Admin::SectionsController; def rescue_action(e) raise e end; end

class Admin::SectionsControllerTest < Test::Unit::TestCase
  fixtures :sections, :users

  def setup
    @controller = Admin::SectionsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    login_as :quentin
  end

  def test_should_list_sections
    get :index
    assert_equal 1, assigns(:sections).length # the home section is shifted off
  end

  def test_should_create_section
    assert_difference Section, :count do
      post :create, :section => { :name => 'foo' }
      assert_response :success
    end
  end

  def test_should_edit_name
    xhr :post, :update, :id => sections(:home).id, :section => { :name => 'foo' }
    sections(:home).reload
    assert_equal 'foo', sections(:home).name
  end

  def test_should_destroy_section
    xhr :post, :destroy, :id => sections(:home).id
    assert_nil Section.find_by_id(sections(:home).id)
  end

  #def test_should_require_ajax
  #  get :create, :id => sections(:home).id, :section => { :name => 'gah' }
  #  assert_redirected_to :action => 'index'
  #  assert flash[:error]
  #
  #  post :create, :id => sections(:home).id, :section => { :name => 'gah' }
  #  assert_redirected_to :action => 'index'
  #  assert flash[:error]
  #end
  #
  #def test_should_require_posted_template
  #  xhr :post, :update, :id => sections(:layout).id
  #  assert_equal '', @request.body
  #end
end
