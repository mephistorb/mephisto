require File.dirname(__FILE__) + '/../../test_helper'
require 'admin/articles_controller'

# Re-raise errors caught by the controller.
class Admin::ArticlesController; def rescue_action(e) raise e end; end

class Admin::ArticlesControllerTest < Test::Unit::TestCase
  fixtures :articles, :tags, :taggings, :users

  def setup
    @controller = Admin::ArticlesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    login_as :quentin
  end

  def test_should_show_articles
    get :index
    assert_equal 6, assigns(:articles).length
  end

  def test_should_create_article
    assert_difference Article, :count do
      xhr :post, :create, :article => { :title => "My Red Hot Car", :summary => "Blah Blah", :description => "Blah Blah" }
      assert_response :success
      assert !assigns(:article).published?
    end
  end

  def test_should_show_default_checked_tags
    get :index
    assert_response :success
    assert_tag :tag => 'input', :attributes => { :name => "article[tag_ids][]", :value => tags(:home).id.to_s }
  end

  def test_should_show_checked_tags
    get :edit, :id => articles(:welcome).id
    assert_response :success
    assert_tag :tag => 'input', :attributes => { :name => "article[tag_ids][]", :value => tags(:home).id.to_s }
    assert_tag :tag => 'input', :attributes => { :name => "article[tag_ids][]", :value => tags(:about).id.to_s }

    get :edit, :id => articles(:another).id
    assert_response :success
    assert_tag :tag => 'input', :attributes => { :name => "article[tag_ids][]", :value => tags(:home).id.to_s }
    assert_no_tag :tag => 'input', :attributes => { :name => "article[tag_ids][]", :value => tags(:about).id.to_s }
  end

  def test_should_create_article_with_given_tags
    xhr :post, :create, :article => { :title => "My Red Hot Car", :summary => "Blah Blah", :description => "Blah Blah", :tag_ids => [tags(:home).id] }
    assert_response :success
    assert_equal [tags(:home)], assigns(:article).tags
  end

  def test_should_update_article_with_no_tags
    post :update, :id => articles(:welcome).id, :article => { :title => "My Red Hot Car", :summary => "Blah Blah", :description => "Blah Blah" }
    assert_redirected_to :action => 'index'
    assert_equal [], assigns(:article).tags
  end

  def test_should_update_article_with_given_tags
    assert_difference Tagging, :count, -1 do
      post :update, :id => articles(:welcome).id, :article => { :title => "My Red Hot Car", :summary => "Blah Blah", :description => "Blah Blah", :tag_ids => [tags(:home).id] }
      assert_redirected_to :action => 'index'
      assert_equal [tags(:home)], assigns(:article).tags
    end
  end

  def test_should_clear_published_date
    assert articles(:welcome).published?
    post :update, :id => articles(:welcome).id, :article => { :title => 'welcome' }
    assert_redirected_to :action => 'index'
    articles(:welcome).reload
    assert !articles(:welcome).published?
  end
end
