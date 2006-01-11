require File.dirname(__FILE__) + '/../test_helper'
require 'mephisto_controller'

# Re-raise errors caught by the controller.
class MephistoController; def rescue_action(e) raise e end; end

class MephistoControllerTest < Test::Unit::TestCase
  fixtures :articles, :tags, :taggings, :templates

  def setup
    @controller = MephistoController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_routing
    with_options :controller => 'mephisto' do |test|
      test.assert_routing '',               :action => 'list',   :tags => []
      test.assert_routing 'about',          :action => 'list',   :tags => ['about']
      test.assert_routing 'search/foo',     :action => 'search', :q => 'foo'
      test.assert_routing '2006',           :action => 'yearly', :year => '2006'
      test.assert_routing '2006/01',        :action => 'month',  :year => '2006', :month => '01'
      test.assert_routing '2006/01/page/1', :action => 'month',  :year => '2006', :month => '01', :page => '1'
      test.assert_routing '2006/01/01',     :action => 'day',    :year => '2006', :month => '01', :day => '01'
      test.assert_routing '2006/01/01/foo', :action => 'show',   :year => '2006', :month => '01', :day => '01', :permalink => 'foo'
    end
  end

  def test_should_list_on_home
    get :list, :tags => []
    assert_equal tags(:home), assigns(:tag)
    assert_equal [articles(:welcome), articles(:another)], assigns(:articles)
  end

  def test_should_show_correct_feed_url
    get :list, :tags => []
    assert_tag :tag => 'link', :type => 'application/atom+xml', :href => '/feed/atom.xml'
  end

  def test_list_by_tags
    get :list, :tags => %w(about)
    assert_equal tags(:about), assigns(:tag)
    assert_equal [articles(:welcome)], assigns(:articles)
  end

  def test_should_render_liquid_templates_on_home
    get :list, :tags => []
    assert_tag :tag => 'h1', :content => 'This is the layout'
    assert_tag :tag => 'p',  :content => 'home'
    assert_tag :tag => 'h2', :content => articles(:welcome).title
    assert_tag :tag => 'h2', :content => articles(:another).title
    assert_tag :tag => 'p',  :content => articles(:welcome).summary
    assert_tag :tag => 'p',  :content => articles(:another).description
  end

  def test_should_render_liquid_templates_by_tags
    get :list, :tags => %w(about)
    assert_tag    :tag => 'p',  :content => 'tag'
    assert_tag    :tag => 'h2', :content => articles(:welcome).title
    assert_no_tag :tag => 'h2', :content => articles(:another).title
    assert_tag    :tag => 'p',  :content => articles(:welcome).summary
    assert_no_tag :tag => 'p',  :content => articles(:another).description
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
               :tag => 'textarea', :attributes => {                  :id => 'comment_description',  :name => 'comment[description]'  } }
  end

  def test_should_show_daily_entries
    date = 4.days.ago
    get :day, :year => date.year, :month => date.month, :day => date.day
    assert_equal [articles(:another)], assigns(:articles)
  end

  def test_should_show_monthly_entries
    date = 4.days.ago
    get :month, :year => date.year, :month => date.month
    assert_equal [articles(:welcome), articles(:another)], assigns(:articles)
  end
end
