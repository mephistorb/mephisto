require File.dirname(__FILE__) + '/../test_helper'
require_dependency 'mephisto_controller'

# Re-raise errors caught by the controller.
class MephistoController; def rescue_action(e) raise e end; end

class MephistoControllerTest < Test::Unit::TestCase
  fixtures :articles, :categories, :categorizations, :attachments

  def setup
    @controller = MephistoController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_routing
    with_options :controller => 'mephisto' do |test|
      test.assert_routing '',               :action => 'list',   :categories => []
      test.assert_routing 'about',          :action => 'list',   :categories => ['about']
      test.assert_routing 'search/foo',     :action => 'search', :q => 'foo'
      test.assert_routing '2006',           :action => 'yearly', :year => '2006'
      test.assert_routing '2006/01',        :action => 'month',  :year => '2006', :month => '01'
      test.assert_routing '2006/01/page/1', :action => 'month',  :year => '2006', :month => '01', :page => '1'
      test.assert_routing '2006/01/01',     :action => 'day',    :year => '2006', :month => '01', :day => '01'
      test.assert_routing '2006/01/01/foo', :action => 'show',   :year => '2006', :month => '01', :day => '01', :permalink => 'foo'
    end
  end

  def test_should_list_on_home
    get :list, :categories => []
    assert_equal categories(:home), assigns(:category)
    assert_equal [articles(:welcome), articles(:another)], assigns(:articles)
  end

  def test_should_show_correct_feed_url
    get :list, :categories => []
    assert_tag :tag => 'link', :attributes => { :type => 'application/atom+xml', :href => '/feed/atom.xml' }
  end

  def test_list_by_categories
    get :list, :categories => %w(about)
    assert_equal categories(:about), assigns(:category)
    assert_equal articles(:welcome), assigns(:article)
  end

  def test_should_show_page
    get :list, :categories => %w(about the_site_map)
    assert_equal categories(:about), assigns(:category)
    assert_equal articles(:site_map), assigns(:article)
  end

  def test_should_render_liquid_templates_on_home
    get :list, :categories => []
    assert_tag :tag => 'h1', :content => 'This is the layout'
    assert_tag :tag => 'p',  :content => 'home'
    assert_tag :tag => 'h2', :content => articles(:welcome).title
    assert_tag :tag => 'h2', :content => articles(:another).title
    assert_tag :tag => 'p',  :content => articles(:welcome).excerpt
    assert_tag :tag => 'p',  :content => articles(:another).body
  end

  def test_should_render_liquid_templates_by_categories
    get :list, :categories => %w(about)
    assert_tag :tag => 'h1', :content => articles(:welcome).title
  end

  def test_should_search_entries
    get :search, :q => 'another'
    assert_equal [articles(:another)], assigns(:articles)
  end

  def test_should_show_entry
    date = 3.days.ago
    get :show, :year => date.year, :month => date.month, :day => date.day, :permalink => 'welcome_to_mephisto'
    assert_equal articles(:welcome).to_liquid['id'], assigns(:article)['id']
  end

  def test_should_show_navigation_on_paged_categories
    get :list, :categories => %w(about)
    assert_tag :tag => 'ul', :attributes => { :id => 'nav' },
               :children => { :count => 3, :only => { :tag => 'li' } }
    assert_tag :tag => 'ul', :attributes => { :id => 'nav' },
               :descendant => { :tag => 'a', :attributes => { :class => 'selected' } }
    assert_tag :tag => 'a', :attributes => { :class => 'selected' }, :content => 'Home'
  end

  def test_should_show_comments_form
    date = 3.days.ago
    get :show, :year => date.year, :month => date.month, :day => date.day, :permalink => 'welcome_to_mephisto'
    assert_tag :tag => 'form',     :descendant => { 
               :tag => 'input',    :attributes => { :type => 'text', :id => 'comment_author',       :name => 'comment[author]'       } }
    assert_tag :tag => 'form',     :descendant => {                                                                                  
               :tag => 'input',    :attributes => { :type => 'text', :id => 'comment_author_url',   :name => 'comment[author_url]'   } }
    assert_tag :tag => 'form',     :descendant => {                                                                                  
               :tag => 'input',    :attributes => { :type => 'text', :id => 'comment_author_email', :name => 'comment[author_email]' } }
    assert_tag :tag => 'form',     :descendant => { 
               :tag => 'textarea', :attributes => {                  :id => 'comment_body',  :name => 'comment[body]'  } }
  end

  def test_should_show_daily_entries
    date = 4.days.ago
    get :day, :year => date.year, :month => date.month, :day => date.day
    assert_equal [articles(:site_map), articles(:about), articles(:another)], assigns(:articles)
  end

  def test_should_show_monthly_entries
    date = 4.days.ago
    get :month, :year => date.year, :month => date.month
    assert_equal [articles(:welcome), articles(:site_map), articles(:about), articles(:another)], assigns(:articles)
  end
end
