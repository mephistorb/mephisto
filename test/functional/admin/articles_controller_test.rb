require File.dirname(__FILE__) + '/../../test_helper'
require 'admin/articles_controller'

# Re-raise errors caught by the controller.
class Admin::ArticlesController; def rescue_action(e) raise e end; end

class Admin::ArticlesControllerTest < Test::Unit::TestCase
  fixtures :contents, :sections, :assigned_sections, :users, :content_drafts, :sites
  set_fixture_class :content_drafts => Article::Draft

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
    assert_equal 5, assigns(:articles).length
  end
  
  def test_should_show_home_section_first
    get :new
    assert_no_tag :tag => 'input', :attributes => { :id => 'draft' }
    assert_equal sections(:home), assigns(:sections).first
  end
  
  def test_should_create_article
    assert_difference Article, :count do
      post :create, :article => { :title => "My Red Hot Car", :excerpt => "Blah Blah", :body => "Blah Blah" }, :submit => :save
      assert_redirected_to :action => 'index'
      assert !assigns(:article).published?
      assert !assigns(:article).new_record?
      assert_equal users(:quentin), assigns(:article).updater
    end
  end
  
  def test_should_create_publish_event
    assert_event_created 'publish' do
      post :create, :article => { :title => "My Red Hot Car", :excerpt => "Blah Blah", :body => "Blah Blah", :published_at => Time.now }, :submit => :save
      assigns(:article).events.first
    end
  end
  
  def test_should_show_validation_error_on_invalid_create
    assert_no_difference Article, :count do
      post :create, :article => { :excerpt => "Blah Blah", :body => "Blah Blah" }, :submit => :save
      assert_response :success
      assert assigns(:article).new_record?
      assert assigns(:article).errors.on(:title)
      assert !assigns(:article).published?
    end
  end
  
  def test_should_show_default_checked_sections
    get :new
    assert_response :success
    assert_tag    :tag => 'form',  :attributes => { :action => '/admin/articles/create' }
    assert_tag    :tag => 'input', :attributes => { :id => "article_section_ids_#{sections(:home).id.to_s}" }
    assert_no_tag :tag => 'input', :attributes => { :id => "article_section_ids_#{sections(:about).id.to_s}", :checked => 'checked' }
  end
  
  def test_should_show_checked_sections
    get :edit, :id => contents(:welcome).id
    assert_response :success
    assert_tag :tag => 'input', :attributes => { :id => "article_section_ids_#{sections(:home).id.to_s}" }
    assert_tag :tag => 'input', :attributes => { :id => "article_section_ids_#{sections(:about).id.to_s}" }
  
    get :edit, :id => contents(:another).id
    assert_response :success
    assert_tag    :tag => 'input', :attributes => { :id => "article_section_ids_#{sections(:home).id.to_s}" }
    assert_no_tag :tag => 'input', :attributes => { :id => "article_section_ids_#{sections(:about).id.to_s}", :checked => 'checked' }
  end
  
  def test_edit_form_should_have_correct_post_action
    get :edit, :id => contents(:welcome).id
    assert_response :success
    assert_tag :tag => 'form', :attributes => { :action => "/admin/articles/update/#{contents(:welcome).id}" }    
  end

  def test_show_action_previews_article
    get :show, :id => contents(:welcome).id
    assert_response :success
  end

  def test_should_create_article_with_given_sections
    post :create, :article => { :title => "My Red Hot Car", :excerpt => "Blah Blah", :body => "Blah Blah", :section_ids => [sections(:home).id.to_s] }, :submit => :save
    assert_redirected_to :action => 'index'
    assert_equal [sections(:home)], assigns(:article).sections
  end
  
  def test_should_update_article_with_no_sections
    post :update, :id => contents(:welcome).id, :article => { :title => "My Red Hot Car", :excerpt => "Blah Blah", :body => "Blah Blah", :section_ids => [] }, :submit => :save
    assert_redirected_to :action => 'index'
    assert_equal [], assigns(:article).sections
  end

  def test_should_update_article_with_the_same_sections
    post :update, :id => contents(:welcome).id, :article => { :title => "My Red Hot Car", :excerpt => "Blah Blah", :body => "Blah Blah",
      :section_ids => [sections(:home), sections(:about)].map { |s| s.id.to_s } }, :submit => :save
    assert_redirected_to :action => 'index'
    assert_equal [sections(:about), sections(:home)], assigns(:article).sections
  end

  def test_should_create_edit_event
    assert_event_created_for :welcome, 'edit' do |article|
      post :update, :id => article.id, :article_published => true, :article => { :title => "My Red Hot Car", :published_at => Time.now }, :submit => :save
    end
  end
  
  def test_should_update_article_with_given_sections
    login_as :arthur
    assert_difference AssignedSection, :count, -1 do
      post :update, :id => contents(:welcome).id, :article => { :title => "My Red Hot Car", :excerpt => "Blah Blah", :body => "Blah Blah", :section_ids => [sections(:home).id] }, :submit => :save
      assert_redirected_to :action => 'index'
      assert_equal [sections(:home)], assigns(:article).sections
      assert_equal users(:arthur),    assigns(:article).updater
    end
  end

  def test_should_show_article_draft
    get :draft, :id => content_drafts(:first).id
    assert_tag :tag => 'input', :attributes => { :id => 'draft', :value => content_drafts(:first).id.to_s }
  end

  def test_should_create_article_draft
    assert_no_difference Article, :count do
      assert_difference Article::Draft, :count_new do
        post :create, :article => { :title => "My Red Hot Car", :excerpt => "Blah Blah", :body => "Blah Blah" }, :submit => :draft
        assert_redirected_to :action => 'index'
        assert assigns(:article).new_record?
        assert !assigns(:article).published?
      end
    end
  end

  def test_should_create_article_draft_from_existing_article
    assert_no_difference Article, :count do
      assert_no_difference Article::Draft, :count_new do # this is not a new draft since it belongs to this article
        assert_difference Article::Draft, :count do
          post :update, :id => contents(:another).id, :article => { :title => "My Red Hot Car", :excerpt => "Blah Blah", :body => "Blah Blah" }, :submit => :draft
          contents(:another).reload
          assert_redirected_to :action => 'index'
          assert_equal contents(:another), assigns(:draft).article
        end
      end
    end
  end

  def test_should_save_over_existing_draft_for_new_article
    assert_no_difference Article, :count do
      assert_no_difference Article::Draft, :count do
        post :create, :article => { :title => "My Red Hot Car", :excerpt => "Blah Blah", :body => "Blah Blah" }, :submit => :draft, :draft => content_drafts(:first).id
        assert_redirected_to :action => 'index'
        assert assigns(:article).new_record?
      end
    end
  end

  def test_should_save_over_existing_draft_for_existing_article
    assert_no_difference Article, :count do
      assert_no_difference Article::Draft, :count do
        post :update, :id => contents(:welcome).id, :article => { :title => "My Red Hot Car", :excerpt => "Blah Blah", :body => "Blah Blah" }, :submit => :draft
        contents(:welcome).reload
        assert_redirected_to :action => 'index'
        assert_equal contents(:welcome), assigns(:draft).article
      end
    end
  end

  def test_should_create_article_and_clear_draft
    assert_difference Article, :count do
      assert_difference Article::Draft, :count, -1 do
        post :create, :article => { :title => "My Red Hot Car", :excerpt => "Blah Blah", :body => "Blah Blah" }, :submit => :save, :draft => content_drafts(:first).id
        assert_redirected_to :action => 'index'
        assert !assigns(:article).published?
        assert !assigns(:article).new_record?
        assert_equal users(:quentin), assigns(:article).updater
        assert_raises(ActiveRecord::RecordNotFound) { content_drafts(:first).reload }
      end
    end
  end

  def test_should_clear_draft_upon_updating_article
    assert_difference Article::Draft, :count, -1 do
      post :update, :id => contents(:welcome).id, :article => { :title => "My Red Hot Car", :excerpt => "Blah Blah", :body => "Blah Blah" }
    end
  end
end
