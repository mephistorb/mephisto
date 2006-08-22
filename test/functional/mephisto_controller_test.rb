require File.dirname(__FILE__) + '/../test_helper'
require_dependency 'mephisto_controller'

# Re-raise errors caught by the controller.
class MephistoController; def rescue_action(e) raise e end; end

class MephistoControllerTest < Test::Unit::TestCase
  fixtures :contents, :sections, :assigned_sections, :sites, :users

  def setup
    prepare_theme_fixtures
    @controller = MephistoController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    host! 'test.com'
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
    get_mephisto
    assert_response :success
    assert_equal sites(:first),                            assigns(:site)
    assert_equal sections(:home),                          assigns(:section)
    assert_equal [contents(:welcome), contents(:another)], assigns(:articles)
    assert_equal sites(:first),                            liquid(:site).source
    assert_equal sections(:home),                          liquid(:section).source
    assert_equal sections(:home),                          liquid(:site).current_section.source
    assert_equal [contents(:welcome), contents(:another)], liquid(:articles).collect(&:source)
    assert liquid(:section).current
  end

  def test_should_show_paged_home
    host! 'cupcake.com'
    get_mephisto
    assert_equal sites(:hostess),            assigns(:site)
    assert_equal sections(:cupcake_home),    assigns(:section)
    assert_equal contents(:cupcake_welcome), assigns(:article)
    assert_nil assigns(:articles)
    assert liquid(:section).current
    assert_equal sections(:cupcake_home), liquid(:site).current_section.source
    assert_response :success
  end

  def test_should_show_error_on_bad_blog_url
    get_mephisto 'foobar/basd'
    assert_equal sites(:first), assigns(:site)
    assert_response :missing
  end

  def test_should_show_error_on_bad_paged_url
    host! 'cupcake.com'
    {'foobar/basd' => sections(:cupcake_home), 'about/foo' => sections(:cupcake_about)}.each do |path, section|
      get_mephisto path
      assert_equal sites(:hostess), assigns(:site)
      assert_equal section,         assigns(:section)
      assert_response :missing
    end
  end

  def test_should_show_correct_feed_url
    get_mephisto
    assert_tag :tag => 'link', :attributes => { :type => 'application/atom+xml', :href => '/feed/atom.xml' }
  end

  def test_list_by_sections
    get_mephisto 'about'
    assert_equal sites(:first), assigns(:site)
    assert_equal sections(:about), assigns(:section)
    assert_equal contents(:welcome), assigns(:article)
  end
  
  def test_list_by_site_sections
    host! 'cupcake.com'
    get_mephisto 'about'
    assert_equal sites(:hostess), assigns(:site)
    assert_equal sections(:cupcake_about), assigns(:section)
    assert_equal contents(:cupcake_welcome), assigns(:article)
  end

  def test_should_show_page
    get_mephisto 'about/the-site-map'
    assert_equal sections(:about), assigns(:section)
    assert_equal contents(:site_map), assigns(:article)
  end

  def test_should_render_liquid_templates_on_home
    get_mephisto
    assert_tag 'h1', :content => 'This is the layout'
    assert_tag 'p',  :content => 'home'
    assert_tag 'h2', :content => contents(:welcome).title
    assert_tag 'h2', :content => contents(:another).title
    assert_tag 'p',  :content => contents(:welcome).excerpt
    assert_tag 'p',  :content => contents(:another).body
  end

  def test_should_show_time_in_correct_timezone
    get_mephisto
    assert_tag 'span', :content => assigns(:site).timezone.utc_to_local(contents(:welcome).published_at).to_s(:standard)
  end

  def test_should_render_liquid_templates_by_sections
    get_mephisto 'about'
    assert_tag :tag => 'h1', :content => contents(:welcome).title
  end

  def test_should_search_entries
    get :search, :q => 'another'
    assert_equal [contents(:another)], assigns(:articles)
    assert_equal sites(:first).articles_per_page, liquid(:site).before_method(:articles_per_page)
    assert_equal 'another', liquid(:search_string)
    assert_equal 1, liquid(:search_count)
  end

  def test_should_show_entry
    date = 3.days.ago
    get :show, :year => date.year, :month => date.month, :day => date.day, :permalink => 'welcome-to-mephisto'
    assert_equal contents(:welcome).to_liquid['id'], assigns(:article)['id']
  end
  
  def test_should_show_site_entry
    host! 'cupcake.com'
    date = 3.days.ago
    get :show, :year => date.year, :month => date.month, :day => date.day, :permalink => 'welcome-to-cupcake'
    assert_equal contents(:cupcake_welcome).to_liquid['id'], assigns(:article)['id']
  end
  
  def test_should_show_error_on_bad_permalink
    date = 3.days.ago
    get :show, :year => date.year, :month => date.month, :day => date.day, :permalink => 'welcome-to-paradise'
    assert_response :missing
  end
  
  def test_should_show_navigation_on_paged_sections
    get_mephisto 'about'
    assert_tag 'ul', :attributes => { :id => 'nav' },
               :children => { :count => 3, :only => { :tag => 'li' } }
    assert_tag 'ul', :attributes => { :id => 'nav' },
               :descendant => { :tag => 'a', :attributes => { :class => 'selected' } }
    assert_tag 'a',  :attributes => { :class => 'selected' }, :content => 'Home'
  end

  def test_should_set_home_page_on_paged_sections
    get_mephisto 'about'
    assert_equal 3, liquid(:pages).size
    [true, false, false].each_with_index do |expected, i|
      assert_equal expected, liquid(:pages)[i][:is_page_home]
    end
  end

  def test_should_set_paged_permalinks
    get_mephisto 'about'
    assert_tag 'a', :attributes => { :href => '/about', :class => 'selected' }, :content => 'Home'
    assert_tag 'a', :attributes => { :href => '/about/about-this-page'       }, :content => 'About'
    assert_tag 'a', :attributes => { :href => '/about/the-site-map'          }, :content => 'The Site Map'
  end

  def test_should_set_paged_permalinks
    get_mephisto 'about/the-site-map'
    assert_tag 'a', :attributes => { :href => '/about'                                    }, :content => 'Home'
    assert_tag 'a', :attributes => { :href => '/about/about-this-page'                    }, :content => 'About'
    assert_tag 'a', :attributes => { :href => '/about/the-site-map', :class => 'selected' }, :content => 'The Site Map'
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
               :tag => 'textarea', :attributes => {                  :id => 'comment_body',         :name => 'comment[body]'  } }
  end

  def test_should_show_daily_entries
    date = 4.days.ago
    get :day, :year => date.year, :month => date.month, :day => date.day
    assert_models_equal [contents(:about), contents(:site_map), contents(:another)], assigns(:articles)
  end

  def test_should_show_monthly_entries
    date = 4.days.ago
    get :month, :year => date.year, :month => date.month
    assert_equal [contents(:welcome), contents(:about), contents(:site_map), contents(:another)], assigns(:articles)
  end
  
  protected
    def get_mephisto(path = '')
      get :list, :sections => path.split('/')
    end
end
