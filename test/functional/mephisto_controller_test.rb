require File.dirname(__FILE__) + '/../test_helper'
require_dependency 'mephisto_controller'

# Re-raise errors caught by the controller.
class MephistoController; def rescue_action(e) raise e end; end

class MephistoControllerTest < Test::Unit::TestCase
  fixtures :contents, :sections, :assigned_sections, :attachments, :db_files, :sites, :users

  def setup
    @controller = MephistoController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    host! 'test.host'
  end

  def test_routing
    with_options :controller => 'mephisto' do |test|
      test.assert_routing '',               :action => 'list',   :sections => []
      test.assert_routing 'about',          :action => 'list',   :sections => %w(about)
      test.assert_routing '2006',           :action => 'yearly', :year => '2006'
      test.assert_routing '2006/01',        :action => 'month',  :year => '2006', :month => '01'
      test.assert_routing '2006/01/page/1', :action => 'month',  :year => '2006', :month => '01', :page => '1'
      test.assert_routing '2006/01/01',     :action => 'day',    :year => '2006', :month => '01', :day => '01'
      test.assert_routing '2006/01/01/foo', :action => 'show',   :year => '2006', :month => '01', :day => '01', :permalink => 'foo'
      test.assert_routing 'mephisto',       :action => 'list', :sections => %w(mephisto)
      test.assert_routing 'stuff/mephisto', :action => 'list', :sections => %w(stuff mephisto)
    end
  end

  def test_should_list_on_home
    get :list, :sections => []
    assert_equal sites(:first), assigns(:site)
    assert_equal sections(:home), assigns(:section)
    assert_equal [contents(:welcome), contents(:another)], assigns(:articles)
  end

  #def test_should_cache_list
  #  get :list, :sections => []
  #  assert_page_cached section_url(:sections => [])
  #end

  def test_should_show_correct_feed_url
    get :list, :sections => []
    assert_tag :tag => 'link', :attributes => { :type => 'application/atom+xml', :href => '/feed/atom.xml' }
  end

  def test_list_by_sections
    get :list, :sections => %w(about)
    assert_equal sites(:first), assigns(:site)
    assert_equal sections(:about), assigns(:section)
    assert_equal contents(:welcome), assigns(:article)
  end
  
  def test_list_by_site_sections
    host! 'cupcake.host'
    get :list, :sections => %w(about)
    assert_equal sites(:hostess), assigns(:site)
    assert_equal sections(:cupcake_about), assigns(:section)
    assert_equal contents(:cupcake_welcome), assigns(:article)
  end

  def test_should_show_page
    get :list, :sections => %w(about the-site-map)
    assert_equal sections(:about), assigns(:section)
    assert_equal contents(:site_map), assigns(:article)
  end

  def test_should_render_liquid_templates_on_home
    get :list, :sections => []
    assert_tag :tag => 'h1', :content => 'This is the layout'
    assert_tag :tag => 'p',  :content => 'home'
    assert_tag :tag => 'h2', :content => contents(:welcome).title
    assert_tag :tag => 'h2', :content => contents(:another).title
    assert_tag :tag => 'p',  :content => contents(:welcome).excerpt
    assert_tag :tag => 'p',  :content => contents(:another).body
  end

  def test_should_render_liquid_templates_by_sections
    get :list, :sections => %w(about)
    assert_tag :tag => 'h1', :content => contents(:welcome).title
  end

  def test_should_search_entries
    get :search, :q => 'another'
    assert_equal [contents(:another)], assigns(:articles)
  end

  def test_should_show_entry
    date = 3.days.ago
    get :show, :year => date.year, :month => date.month, :day => date.day, :permalink => 'welcome-to-mephisto'
    assert_equal contents(:welcome).to_liquid['id'], assigns(:article)['id']
  end
  
  def test_should_show_site_entry
    host! 'cupcake.host'
    date = 3.days.ago
    get :show, :year => date.year, :month => date.month, :day => date.day, :permalink => 'welcome-to-cupcake'
    assert_equal contents(:cupcake_welcome).to_liquid['id'], assigns(:article)['id']
  end
  
  def test_should_show_navigation_on_paged_sections
    get :list, :sections => %w(about)
    assert_tag :tag => 'ul', :attributes => { :id => 'nav' },
               :children => { :count => 3, :only => { :tag => 'li' } }
    assert_tag :tag => 'ul', :attributes => { :id => 'nav' },
               :descendant => { :tag => 'a', :attributes => { :class => 'selected' } }
    assert_tag :tag => 'a', :attributes => { :class => 'selected' }, :content => 'Home'
  end

  def test_should_show_comments_form
    date = 3.days.ago
    get :show, :year => date.year, :month => date.month, :day => date.day, :permalink => 'welcome-to-mephisto'
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
    assert_equal [contents(:about), contents(:site_map), contents(:another)], assigns(:articles)
  end

  def test_should_show_monthly_entries
    date = 4.days.ago
    get :month, :year => date.year, :month => date.month
    assert_equal [contents(:welcome), contents(:about), contents(:site_map), contents(:another)], assigns(:articles)
  end
end
