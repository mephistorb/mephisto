require File.dirname(__FILE__) + '/../../test_helper'
require 'admin/sections_controller'

# Re-raise errors caught by the controller.
class Admin::SectionsController; def rescue_action(e) raise e end; end

class Admin::SectionsControllerTest < Test::Unit::TestCase
  fixtures :sections, :users, :contents, :assigned_sections, :sites, :memberships

  def setup
    @controller = Admin::SectionsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    login_as :quentin
  end

  def test_should_list_sections
    get :index
    assert_equal sites(:first), assigns(:site)
    assert_equal sections(:home), assigns(:home)
    assert_equal 6, assigns(:sections).length, "Sections: #{assigns(:sections).inspect}"
    assert_equal 3, assigns(:article_count)['1']
    assert_equal 3, assigns(:article_count)['2']
  end

  def test_should_create_blog_section
    assert_difference Section, :count do
      xhr :post, :create, :section => { :name => 'foo', :path => '', :show_paged_articles => '0', :template => 'foo', :layout => 'bar' }
      assert_response :success
      assert             !assigns(:section).show_paged_articles?
      assert_equal 'foo', assigns(:section).name
      assert_equal 'foo', assigns(:section).template
      assert_equal 'bar', assigns(:section).layout
    end
  end

  def test_should_create_paged_section
    assert_difference Section, :count do
      xhr :post, :create, :section => { :name => 'foo', :path => '', :show_paged_articles => '1', :template => 'foo', :layout => 'bar' }
      assert_response :success
      assert assigns(:section).show_paged_articles?
      assert_equal 'foo', assigns(:section).template
      assert_equal 'bar', assigns(:section).layout
    end
  end

  def test_should_create_section_with_empty_templates
    assert_difference Section, :count do
      xhr :post, :create, :section => { :name => 'foo', :path => '', :show_paged_articles => '0', :template => '-', :layout => '-', :archive_template => '-' }
      assert_response :success
      assert             !assigns(:section).show_paged_articles?
      assert_equal 'foo', assigns(:section).name
      assert_nil assigns(:section).template
      assert_nil assigns(:section).layout
      assert_nil assigns(:section).archive_template
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

  def test_should_reorder_articles
    assert_reorder_articles sections(:about),
      [contents(:welcome), contents(:about), contents(:site_map)],
      [contents(:about), contents(:site_map), contents(:welcome)]
  end

  def test_should_destroy_section
    xhr :post, :destroy, :id => sections(:home).id
    assert_nil Section.find_by_id(sections(:home).id)
  end

  def assert_reorder_articles(section, old_order, expected)
    assert_equal old_order, section.articles
    xhr :post, :order, :id => section.id, :article_ids => expected.collect(&:id)
    assert_equal expected, section.articles(true)
  end
end
