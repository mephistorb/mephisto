require File.dirname(__FILE__) + '/../../test_helper'

# Re-raise errors caught by the controller.
class Admin::ArticlesController; def rescue_action(e) raise e end; end

class Admin::ArticlesControllerTest < Test::Unit::TestCase
  fixtures :contents, :content_versions, :sections, :assigned_sections, :users, :sites, :tags, :taggings, :memberships

  def setup
    @controller = Admin::ArticlesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    login_as :quentin
  end

  def test_should_require_login
    login_as nil
    get :index
    assert_redirected_to :controller => '/account', :action => 'login'
  end

  def test_should_accept_cookie_login
    login_with_cookie_as :quentin
    get :index
    assert_response :success
  end
  
  def test_should_show_articles
    get :index
    assert_equal 12, assigns(:articles).length
  end
  
  def test_should_show_articles_with_empty_seartest_should_show_checked_sectionsch
    get :index, :q => '', :filter => 'title', :section => '0'
    assert_equal 12, assigns(:articles).length
  end

  def test_should_search_article_titles
    get :index, :q => 'future', :filter => 'title'
    assert_response :success
    assert_models_equal [contents(:future)], assigns(:articles)
  end

  def test_should_search_article_tags
    get :index, :q => 'rails', :filter => 'tags'
    assert_response :success
    assert_models_equal [contents(:future), contents(:another)], assigns(:articles)
  end

  def test_should_search_article_body
    get :index, :q => 'welcome', :filter => 'body'
    assert_response :success
    assert_models_equal [contents(:welcome), contents(:another)], assigns(:articles)
  end

  def test_should_search_article_by_section
    get :index, :filter => 'section', :section => '2'
    assert_response :success
    assert_models_equal [contents(:future), contents(:welcome), contents(:about), contents(:site_map), contents(:draft)], assigns(:articles)
  end

  def test_should_search_article_by_section_and_title
    get :index, :filter => 'title', :q => 'welcome', :section => '2'
    assert_response :success
    assert_models_equal [contents(:welcome)], assigns(:articles)
  end

  def test_should_show_home_section_first
    get :new
    assert_no_tag :tag => 'input', :attributes => { :id => 'draft' }
    assert_equal sections(:home), assigns(:sections).first
  end

  def test_should_show_timezone_published_date
    Time.mock! Time.local(2005, 1, 1, 10, 0, 0) do
      get :new
      assert_no_tag 'select', :attributes => { :name => 'article[expire_comments_at(1i)]' }
      assert_response :success
      assert_tag 'option', :content => '11', :attributes => { :selected => 'selected' }, 
        :ancestor => { :tag => 'select', :attributes => { :name => 'article[published_at(4i)]' } }
    end
  end

  def test_should_create_article
    Time.mock! Time.local(2005, 1, 1, 12, 0, 0) do
      assert_difference Article, :count do
        post :create, :article => { :title => "My Red Hot Car", :excerpt => "Blah Blah", :body => "Blah Blah",
          'published_at(1i)' => '2005', 'published_at(2i)' => '1', 'published_at(3i)' => '1', 'published_at(4i)' => '10' }, :submit => :save
        assert_redirected_to :action => 'edit', :id => assigns(:article)
        assert  assigns(:article).published?
        assert_equal Time.local(2005, 1, 1, 9, 0, 0).utc, assigns(:article).published_at
        assert !assigns(:article).new_record?
        assert_equal users(:quentin), assigns(:article).updater
      end
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

  def test_should_show_correct_sections_on_invalid_create
    assert_no_difference Article, :count do
      post :create, :article =>  {:excerpt => "Blah Blah", :body => "Blah Blah", :section_ids => {'2' => "true", '1' => ''}}, :submit => :save
      assert_response :success
      assert assigns(:article).new_record?
      assert_tag :tag => 'input', :attributes => {:id => "article_section_ids_#{sections(:about).id.to_s}", :checked => 'checked'}
    end
  end

  def test_should_show_default_checked_sections
    get :new
    assert_response :success
    assert_tag    'form',  :attributes => { :action => '/admin/articles', :method => 'post' }
    assert_tag    'input', :attributes => { :id => "article_section_ids_#{sections(:home).id.to_s}" }
    assert_no_tag 'input', :attributes => { :id => "article_section_ids_#{sections(:about).id.to_s}", :checked => 'checked' }
  end

  def test_should_show_title
    get :edit, :id => contents(:welcome).id
    assert_response :success
    assert_tag 'input', :attributes => { :id => 'article_title', :value => contents(:welcome).title }
  end

  def test_should_edit_article_version
    get :edit, :id => contents(:welcome).id, :version => '1'
    assert_tag 'input', :attributes => { :id => 'article_title', :value => contents(:welcome).title + '!!!!!!' }
  end

  def test_should_show_checked_sections
    get :edit, :id => contents(:welcome).id
    assert_response :success
    assert_tag 'input', :attributes => { :id => "article_section_ids_#{sections(:home).id.to_s}" }
    assert_tag 'input', :attributes => { :id => "article_section_ids_#{sections(:about).id.to_s}" }
  
    get :edit, :id => contents(:another).id
    assert_response :success
    assert_tag  'input', :attributes => { :id => "article_section_ids_#{sections(:home).id.to_s}", :checked => 'checked' }
  end

  def test_should_show_available_years
    get :new
    [Time.now.utc.year, Time.now.utc.year-1].each do |year|
      assert_select "select[name='article[published_at(1i)]'] option[value='#{year}']"
    end
  end

  def test_should_show_available_years_for_old_article
    contents(:welcome).update_attribute(:published_at, Time.utc(2003,1,1))
    get :edit, :id => contents(:welcome).id
    (2003..2007).to_a.each do |year|
      assert_select "select[name='article[published_at(1i)]'] option[value='#{year}']"
    end
  end

  def test_should_show_published_date_selector
    get :edit, :id => contents(:welcome).id
    local_time = assigns(:article).published_at
    assert_tag 'select', :attributes => { :name => "article[#{:published_at}(1i)]" }
    [ :year, :month, :day, :hour, :min ].each_with_index do |attr, i|
      value = local_time.send(attr)
      assert_select "select[name='article[published_at(#{i+1}i)]'] option[selected='selected']" do
        assert_select "[value='#{(i > 2 ? local_time.send(attr).to_s.rjust(2, '0') : value.to_s)}']"
      end
    end
  end
  
  def test_edit_form_should_have_correct_post_action
    get :edit, :id => contents(:welcome).id
    assert_response :success
    assert_tag :tag => 'form', :attributes => { :action => "/admin/articles/#{contents(:welcome).id}" } do
      assert_tag :tag => 'input', :attributes => { :name => "_method", :value => "put" }
    end
  end

  def test_should_update_article_with_correct_time
    Time.mock! Time.local(2005, 1, 1, 12, 0, 0) do
      post :update, :id => contents(:welcome).id, :article => { 'published_at(1i)' => '2005', 'published_at(2i)' => '1', 'published_at(3i)' => '1', 'published_at(4i)' => '10' }
      assert  assigns(:article).published?
      assert_equal Time.local(2005, 1, 1, 9, 0, 0).utc, assigns(:article).published_at
    end
  end

  def test_should_create_article_with_given_sections
    post :create, :article => { :title => "My Red Hot Car", :excerpt => "Blah Blah", :body => "Blah Blah", :section_ids => [sections(:home).id.to_s] }, :submit => :save
    assert_redirected_to :action => 'edit', :id => assigns(:article).id
    assert_equal [sections(:home)], assigns(:article).sections
  end
  
  def test_should_update_article_with_no_sections
    post :update, :id => contents(:welcome).id, :article => { :title => "My Red Hot Car", :excerpt => "Blah Blah", :body => "Blah Blah", :section_ids => [] }, :submit => :save
    assert_redirected_to :action => 'edit', :id => assigns(:article).id
    assert_equal [], assigns(:article).sections
  end

  def test_should_update_article_with_the_same_sections
    post :update, :id => contents(:welcome).id, :article => { :title => "My Red Hot Car", :excerpt => "Blah Blah", :body => "Blah Blah",
      :section_ids => [sections(:home), sections(:about)].map { |s| s.id.to_s } }, :submit => :save
    assert_redirected_to :action => 'edit', :id => assigns(:article).id
    assert_equal [sections(:about), sections(:home)], assigns(:article).sections
  end

  def test_should_create_edit_event
    assert_event_created_for :welcome, 'edit' do |article|
      post :update, :id => article.id, :article_published => true, :article => { :title => "My Red Hot Car", :published_at => 5.days.ago }, :submit => :save
      assert !assigns(:article).new_record?
      assert  assigns(:article).published?
    end
  end
  
  def test_should_update_article_with_given_sections
    login_as :arthur
    assert_difference AssignedSection, :count, -1 do
      post :update, :id => contents(:welcome).id, :article => { :title => "My Red Hot Car", :excerpt => "Blah Blah", :body => "Blah Blah", :section_ids => [sections(:home).id] }, :submit => :save
      assert_redirected_to :action => 'edit', :id => assigns(:article).id
      assert_equal [sections(:home)], assigns(:article).sections
      assert_equal users(:arthur),    assigns(:article).updater
    end
  end

  def test_should_update_and_show_notice_for_save_and_keep_editing
    xhr :post, :update, :id => contents(:welcome).id, :article => { 
      :title => "My Red Hot Car", :excerpt => "Blah Blah", :body => "Blah Blah",
      :section_ids => [sections(:home), sections(:about)].map { |s| s.id.to_s } }, :commit => 'Apply changes and keep editing'

    assert @response.body.grep(/Flash\.notice/)
  end 

  def test_should_create_new_article_with_default_comment_age
    [:first, :hostess, :garden].each do |site|
      login_as :quentin do
        host! sites(site).host
        get :new
        assert_response :success
        assert_equal sites(site).comment_age, assigns(:article).comment_age, "error on #{sites(site).title}"
      end
    end
  end
  
  def test_should_show_published_enabled_by_default
    get :index
    assert_response :success
    assert_select "input#published[value='1']"
  end

  def test_should_show_draft_checkbox_for_new_articles
    get :new
    assert_response :success
    assert_draft_check_box
    assert_publish_date_select :hidden
  end

  def test_should_not_show_draft_checkbox_for_published_articles
    get :edit, :id => contents(:about)
    assert_response :success
    assert_draft_check_box
    assert_publish_date_select :hidden
  end

  def test_should_show_draft_checkbox_for_unpublished_articles
    get :edit, :id => contents(:draft)
    assert_response :success
    assert_draft_check_box
    assert_publish_date_select
  end

  def test_should_create_article_draft
    assert_difference Article, :count do
      post :create, :article => { :title => "My Red Hot Car", :excerpt => "Blah Blah", :body => "Blah Blah", :published_at => 5.days.ago }, :draft => '1'
      assert_nil @controller.params['published_at']
      assert_redirected_to :action => 'edit', :id => assigns(:article).id
      assert !assigns(:article).new_record?
      assert !assigns(:article).published?
      assert_nil assigns(:article).published_at
    end
  end

  def test_should_change_article_to_draft
    post :update, :id => contents(:welcome).id, :draft => '1'
      assert !assigns(:article).published?
      assert_nil assigns(:article).published_at
  end

  def test_should_save_article_without_revision
    assert_no_difference Article::Version, :count do
      post :update, :id => contents(:welcome).id, :article => { :title => 'Foo' }, :commit => 'Save without Revision'
    end
  end

  protected
    def assert_draft_check_box(visibility = true)
      assert_tag_visibility visibility, 'label', :attributes => { :for => 'article-draft' }
      assert_tag_visibility visibility, 'input', :attributes => { :type => 'checkbox', :id => 'article-draft', :name => 'draft', :value => '1' }
    end

    def assert_publish_date_select(visibility = true)
      assert_tag 'dt', :attributes => { :id => 'publish-date-lbl' }
      assert_tag 'dd', :attributes => { :id => 'publish-date' }
      assert_tag_visibility visibility, 'dt', :attributes => { :id => 'publish-date-lbl', :style => 'display:none' }
      assert_tag_visibility visibility, 'dd', :attributes => { :id => 'publish-date',     :style => 'display:none' }
    end
    
    def assert_tag_visibility(visibility, *args)
      send *(args.unshift(visibility != :hidden ? :assert_tag : :assert_no_tag))
    end
end
