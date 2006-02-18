require File.dirname(__FILE__) + '/../../test_helper'
require 'admin/articles_controller'

# Re-raise errors caught by the controller.
class Admin::ArticlesController; def rescue_action(e) raise e end; end

class Admin::ArticlesControllerTest < Test::Unit::TestCase
  fixtures :contents, :categories, :categorizations, :users

  def setup
    @controller = Admin::ArticlesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    login_as :quentin
  end

  def test_should_require_login
    login_as nil
    get :index
    assert_redirected_to :controller => 'account', :action => 'login'
  end

  def test_should_accept_cookie_login
    login_with_cookie_as :quentin
    get :index
    assert_response :success
  end

  def test_should_show_articles
    get :index
    assert_equal 6, assigns(:articles).length
  end

  def test_should_create_article
    assert_difference Article, :count do
      post :create, :article => { :title => "My Red Hot Car", :excerpt => "Blah Blah", :body => "Blah Blah" }
      assert_redirected_to :action => 'index'
      assert !assigns(:article).published?
    end
  end

  def test_should_show_validation_error_on_invalid_create
    assert_no_difference Article, :count do
      post :create, :article => { :excerpt => "Blah Blah", :body => "Blah Blah" }
      assert_response :success
      assert assigns(:article).new_record?
      assert assigns(:article).errors.on(:title)
      assert !assigns(:article).published?
    end
  end

  def test_should_show_default_checked_categories
    get :new
    assert_response :success
    assert_tag    :tag => 'input', :attributes => { :id => "article_category_ids_#{categories(:home).id.to_s}" }
    assert_no_tag :tag => 'input', :attributes => { :id => "article_category_ids_#{categories(:about).id.to_s}", :checked => 'checked' }
  end

  def test_should_show_checked_categories
    get :edit, :id => contents(:welcome).id
    assert_response :success
    assert_tag :tag => 'input', :attributes => { :id => "article_category_ids_#{categories(:home).id.to_s}" }
    assert_tag :tag => 'input', :attributes => { :id => "article_category_ids_#{categories(:about).id.to_s}" }

    get :edit, :id => contents(:another).id
    assert_response :success
    assert_tag    :tag => 'input', :attributes => { :id => "article_category_ids_#{categories(:home).id.to_s}" }
    assert_no_tag :tag => 'input', :attributes => { :id => "article_category_ids_#{categories(:about).id.to_s}", :checked => 'checked' }
  end
  
  def test_edit_form_should_have_correct_post_action
    get :edit, :id => contents(:welcome).id
    assert_response :success
    assert_tag :tag => 'form', :attributes => { :action => "/admin/articles/update/#{contents(:welcome).id}" }    
  end

  def test_should_create_article_with_given_categories
    post :create, :article => { :title => "My Red Hot Car", :excerpt => "Blah Blah", :body => "Blah Blah", :category_ids => [categories(:home).id] }
    assert_redirected_to :action => 'index'
    assert_equal [categories(:home)], assigns(:article).categories
  end

  def test_should_update_article_with_no_categories
    post :update, :id => contents(:welcome).id, :article => { :title => "My Red Hot Car", :excerpt => "Blah Blah", :body => "Blah Blah" }
    assert_redirected_to :action => 'index'
    assert_equal [], assigns(:article).categories
  end

  def test_should_update_article_with_given_categories
    assert_difference Categorization, :count, -1 do
      post :update, :id => contents(:welcome).id, :article => { :title => "My Red Hot Car", :excerpt => "Blah Blah", :body => "Blah Blah", :category_ids => [categories(:home).id] }
      assert_redirected_to :action => 'index'
      assert_equal [categories(:home)], assigns(:article).categories
    end
  end

  def test_should_clear_published_date
    assert contents(:welcome).published?
    post :update, :id => contents(:welcome).id, :article => { :title => 'welcome' }
    assert_redirected_to :action => 'index'
    contents(:welcome).reload
    assert !contents(:welcome).published?
  end
end
