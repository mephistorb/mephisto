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
    assert_equal 2, assigns(:sections).length # the home section is shifted off
  end

  def test_should_create_paged_section
    assert_difference Section, :count do
      xhr :post, :create, :section => { :name => 'foo', :show_paged_articles => '0', :template => 'foo', :layout => 'bar' }
      assert_response :success
      assert             !assigns(:section).show_paged_articles?
      assert_equal 'foo', assigns(:section).name
      assert_equal 'foo', assigns(:section).template
      assert_equal 'bar', assigns(:section).layout
    end
  end

  def test_should_create_paged_section
    assert_difference Section, :count do
      xhr :post, :create, :section => { :name => 'foo', :show_paged_articles => '1', :template => 'foo', :layout => 'bar' }
      assert_response :success
      assert assigns(:section).show_paged_articles?
    end
  end

  def test_should_edit_section
    xhr :post, :update, :id => sections(:about).id, :section => { :name => 'foo', :show_paged_articles => '1', :template => 'foo', :layout => 'bar' }
    sections(:about).reload
    assert              sections(:about).show_paged_articles?
    assert_equal 'foo', sections(:about).name
    assert_equal 'foo', sections(:about).template
    assert_equal 'bar', sections(:about).layout
  end

  def test_should_destroy_section
    xhr :post, :destroy, :id => sections(:home).id
    assert_nil Section.find_by_id(sections(:home).id)
  end
end
