require File.dirname(__FILE__) + '/../test_helper'
require_dependency 'mephisto_controller'

# Re-raise errors caught by the controller.
class MephistoController; def rescue_action(e) raise e end; end

class MephistoControllerTest < Test::Unit::TestCase
  fixtures :contents, :content_versions, :sections, :assigned_sections, :sites, :users

  def setup
    prepare_theme_fixtures
    @controller = MephistoController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    host! 'test.com'
  end

  def test_should_list_on_home
    dispatch
    assert_dispatch_action :list
    assert_preferred_template :home
    assert_layout_template    :layout
    assert_template_type      :section
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
    dispatch
    assert_dispatch_action :page
    assert_preferred_template :home
    assert_layout_template    :layout
    assert_template_type      :page
    assert_equal sites(:hostess),            assigns(:site)
    assert_equal sections(:cupcake_home),    assigns(:section)
    assert_equal contents(:cupcake_welcome), assigns(:article)
    assert_nil assigns(:articles)
    assert liquid(:section).current
    assert_equal sections(:cupcake_home), liquid(:site).current_section.source
    assert_response :success
  end

  def test_should_show_error_on_bad_blog_url
    dispatch 'foobar/basd'
    assert_dispatch_action :error
    assert_preferred_template :error
    assert_layout_template    :layout
    assert_template_type      :error
    assert_equal sites(:first), assigns(:site)
    assert_response :missing
  end

  def test_should_show_error_on_bad_paged_url
    host! 'cupcake.com'
    dispatch 'foobar/basd'
    assert_dispatch_action :error
    assert_equal sites(:hostess), assigns(:site)
    assert_equal sections(:cupcake_home),         assigns(:section)
    assert_response :missing
  end

  def test_should_show_error_on_bad_paged_section
    host! 'cupcake.com'
    dispatch 'about/foo'
    assert_dispatch_action :page
    assert_equal sites(:hostess), assigns(:site)
    assert_equal sections(:cupcake_about),         assigns(:section)
    assert_response :missing
  end

  def test_should_show_correct_feed_url
    dispatch
    assert_dispatch_action :list
    assert_tag :tag => 'link', :attributes => { :type => 'application/atom+xml', :href => '/feed/atom.xml' }
  end

  def test_list_by_sections
    dispatch 'about'
    assert_equal sites(:first), assigns(:site)
    assert_equal sections(:about), assigns(:section)
    assert_equal contents(:welcome), assigns(:article)
    assert_preferred_template :page
    assert_layout_template    :layout
    assert_template_type      :page
    assert_dispatch_action    :page
  end
  
  def test_list_by_site_sections
    host! 'cupcake.com'
    dispatch 'about'
    assert_equal sites(:hostess), assigns(:site)
    assert_equal sections(:cupcake_about), assigns(:section)
    assert_equal contents(:cupcake_welcome), assigns(:article)
  end

  def test_should_show_page
    dispatch 'about/the-site-map'
    assert_equal sections(:about), assigns(:section)
    assert_equal contents(:site_map), assigns(:article)
    assert_dispatch_action :page
  end

  def test_should_render_liquid_templates_on_home
    dispatch
    assert_tag 'h1', :content => 'This is the layout'
    assert_tag 'p',  :content => 'home'
    assert_tag 'h2', :content => contents(:welcome).title
    assert_tag 'h2', :content => contents(:another).title
  end

  def test_article_body_with_excerpt_on_list
    assert contents(:welcome).update_attributes(:body => 'body', :excerpt => 'excerpt'), contents(:welcome).errors.full_messages.to_sentence
    dispatch
    assert_select "div#has_excerpt_1"
    assert_select "div#article_excerpt_1 p", 'excerpt'
    assert_select "div#article_body_1 p",    'body'
    assert_select "div#article_content_1 p", 'excerpt'
  end
  
  def test_article_only_body_on_list
    assert contents(:welcome).update_attributes(:body => 'body', :excerpt => nil), contents(:welcome).errors.full_messages.to_sentence
    dispatch
    assert_select "div#no_excerpt_1"
    assert_select "div#article_excerpt_1",   ''
    assert_select "div#article_body_1 p",    'body'
    assert_select "div#article_content_1 p", 'body'
  end
  
  def test_article_only_body_with_empty_excerpt_on_list
    assert contents(:welcome).update_attributes(:body => 'body', :excerpt => ''), contents(:welcome).errors.full_messages.to_sentence
    dispatch
    assert_select "div#no_excerpt_1"
    assert_select "div#article_excerpt_1",   ''
    assert_select "div#article_body_1 p",    'body'
    assert_select "div#article_content_1 p", 'body'
  end

  def test_article_body_with_excerpt_on_single
    a = contents(:welcome)
    assert contents(:welcome).update_attributes(:body => 'body', :excerpt => 'excerpt'), contents(:welcome).errors.full_messages.to_sentence
    dispatch a.site.permalink_for(a)
    assert_select "div#has_excerpt_1"
    assert_select "div#article_excerpt_1 p", 'excerpt'
    assert_select "div#article_body_1 p",    'body'
    assert_select "div#article_content_1 p", 'body'
  end
  
  def test_article_only_body_on_single
    a = contents(:welcome)
    assert contents(:welcome).update_attributes(:body => 'body', :excerpt => nil), contents(:welcome).errors.full_messages.to_sentence
    dispatch a.site.permalink_for(a)
    assert_select "div#no_excerpt_1"
    assert_select "div#article_excerpt_1",   ''
    assert_select "div#article_body_1 p",    'body'
    assert_select "div#article_content_1 p", 'body'
  end
  
  def test_article_only_body_with_empty_excerpt_on_single
    a = contents(:welcome)
    assert contents(:welcome).update_attributes(:body => 'body', :excerpt => ''), contents(:welcome).errors.full_messages.to_sentence
    dispatch a.site.permalink_for(a)
    assert_select "div#no_excerpt_1"
    assert_select "div#article_excerpt_1",   ''
    assert_select "div#article_body_1 p",    'body'
    assert_select "div#article_content_1 p", 'body'
  end

  def test_should_show_time_in_correct_timezone
    dispatch
    assert_tag 'span', :content => assigns(:site).timezone.utc_to_local(contents(:welcome).published_at).to_s(:standard)
  end

  def test_should_render_liquid_templates_by_sections
    dispatch 'about'
    assert_dispatch_action :page
    assert_tag :tag => 'h1', :content => "#{contents(:welcome).title} in #{sections(:about).name}"
  end

  def test_should_render_with_alternate_search_layout
    sites(:first).update_attribute :search_layout, 'alt_layout.liquid'
    dispatch 'search'
    assert_dispatch_action :search
    assert_preferred_template :search
    assert_layout_template    :alt_layout
    assert_template_type      :search
  end

  def test_should_search_entries
    dispatch 'search', :q => 'another'
    assert_dispatch_action :search
    assert_equal [contents(:another)], assigns(:articles)
    assert_equal sites(:first).articles_per_page, liquid(:site).before_method(:articles_per_page)
    assert_equal 'another', liquid(:search_string)
    assert_equal 1, liquid(:search_count)
    assert_preferred_template :search
    assert_layout_template    :layout
    assert_template_type      :search
  end

  def test_should_search_and_not_find_draft
    dispatch 'search', :q => 'draft'
    assert_dispatch_action :search
    assert_equal [], assigns(:articles)
    assert_preferred_template :search
    assert_layout_template    :layout
    assert_template_type      :search
  end

  def test_should_search_and_not_find_future
    dispatch 'search', :q => 'future'
    assert_dispatch_action :search
    assert_equal [], assigns(:articles)
    assert_preferred_template :search
    assert_layout_template    :layout
    assert_template_type      :search
  end

  def test_should_show_entry
    date = contents(:welcome).published_at
    dispatch "#{date.year}/#{date.month}/#{date.day}/welcome-to-mephisto"
    assert_equal contents(:welcome).to_liquid['id'], assigns(:article)['id']
    assert_preferred_template :single
    assert_layout_template    :layout
    assert_template_type      :single
    assert_dispatch_action    :single
  end

  def test_should_show_comment_feed
    date = contents(:welcome).published_at
    dispatch "#{date.year}/#{date.month}/#{date.day}/welcome-to-mephisto/comments.xml"
    assert_response :success
    assert_atom_entries_size 1
  end

  def test_should_show_changes_feed
    date = contents(:welcome).published_at
    dispatch "#{date.year}/#{date.month}/#{date.day}/welcome-to-mephisto/changes.xml"
    assert_response :success
    assert_atom_entries_size 2
  end

  def test_should_show_site_entry
    host! 'cupcake.com'
    date = contents(:cupcake_welcome).published_at
    dispatch "#{contents(:cupcake_welcome).year}/#{contents(:cupcake_welcome).month}/#{contents(:cupcake_welcome).day}/#{contents(:cupcake_welcome).permalink}"
    assert_dispatch_action :single
    assert_template_type   :single
    assert_equal contents(:cupcake_welcome).to_liquid['id'], assigns(:article)['id']
  end
  
  def test_should_show_error_on_bad_permalink
    dispatch "#{contents(:cupcake_welcome).year}/#{contents(:cupcake_welcome).month}/#{contents(:cupcake_welcome).day}/welcome-to-paradise"
    assert_response :missing
    assert_dispatch_action :single
  end
  
  def test_should_show_navigation_on_paged_sections
    dispatch 'about'
    assert_tag 'ul', :attributes => { :id => 'nav' },
               :children => { :count => 3, :only => { :tag => 'li' } }
    assert_tag 'ul', :attributes => { :id => 'nav' },
               :descendant => { :tag => 'a', :attributes => { :class => 'selected' } }
    assert_tag 'a',  :attributes => { :class => 'selected' }, :content => 'Welcome to Mephisto'
  end

  def test_should_set_home_page_on_paged_sections
    dispatch 'about'
    assert_equal 3, liquid(:section).pages.size
    [true, false, false].each_with_index do |expected, i|
      assert_equal expected, liquid(:section).pages[i][:is_page_home]
    end
  end

  def test_should_set_paged_permalinks
    dispatch 'about'
    assert_select 'ul#nav' do
      assert_select "a[href='/about']", 'Welcome to Mephisto' do
        assert_select "[class='selected']"
      end
      assert_select "a[href='/about/about-this-page']", 'About this page'
      assert_select "a[href='/about/the-site-map']", 'The Site Map'
    end
  end

  def test_should_set_paged_permalinks_on_sub_page
    dispatch 'about/the-site-map'
    assert_select 'ul#nav' do
      assert_select "a[href='/about']", 'Welcome to Mephisto'
      assert_select "a[href='/about/about-this-page']", 'About this page'
      assert_select "a[href='/about/the-site-map']", 'The Site Map' do
        assert_select "[class='selected']"
      end
    end
  end

  def test_should_sanitize_comment
    date = contents(:welcome).published_at
    dispatch "#{date.year}/#{date.month}/#{date.day}/welcome-to-mephisto"
    evil = %(<p>rico&#8217;s evil <script>hi</script> and <a onclick="foo" href="#">linkage</a></p>)
    good = %(<p>rico&#8217;s evil &lt;script>hi&lt;/script> and <a href='#'>linkage</a></p>)
    assert !@response.body.include?(evil), "includes unsanitized code"
    assert  @response.body.include?(good), "does not include sanitized code"
  end

  def test_should_show_comments_form
    date = contents(:welcome).published_at
    dispatch "#{date.year}/#{date.month}/#{date.day}/welcome-to-mephisto"
    assert_dispatch_action :single
    assert_select "form#comment-form", :count => 1 do |e|
      assert_equal "#{contents(:welcome).full_permalink}/comments#comment-form", e.first.attributes['action']
      assert_select "input[type='text']", :count => 3
      assert_select "input#comment_author" do |e|
        assert_equal 'text', e.first.attributes['type']
        assert_equal 'comment[author]', e.first.attributes['name']
      end
      assert_select "input#comment_author_email" do |e|
        assert_equal 'text', e.first.attributes['type']
        assert_equal 'comment[author_email]', e.first.attributes['name']
      end
      assert_select "input#comment_author_url" do |e|
        assert_equal 'text', e.first.attributes['type']
        assert_equal 'comment[author_url]', e.first.attributes['name']
      end
      assert_select "textarea#comment_body" do |e|
        assert_equal 'comment[body]', e.first.attributes['name']
      end
    end
  end

  def test_should_reject_get_request_to_comments
    date      = contents(:welcome).published_at
    permalink = "#{date.year}/#{date.month}/#{date.day}/welcome-to-mephisto"
    dispatch "#{permalink}/comments"
    assert_redirected_to permalink
  end

  def test_should_reject_bad_post_request_to_comments
    date      = contents(:welcome).published_at
    permalink = "#{date.year}/#{date.month}/#{date.day}/welcome-to-mephisto"
    dispatch "#{permalink}/comments", :method => :post
    assert_redirected_to permalink
  end

  def test_should_show_monthly_entries
    date = Time.now.utc - 4.days
    dispatch "archives/#{date.year}/#{date.month}"
    assert_dispatch_action :archives
    assert_models_equal [contents(:welcome), contents(:another)], assigns(:articles)
  end
  
  def test_should_show_articles_by_tag
    dispatch "tags/rails"
    assert_dispatch_action :tags
    assert_preferred_template :tag
    assert_layout_template    :layout
    assert_template_type      :tag
    assert_models_equal [contents(:another)], assigns(:articles)
  end

  def test_should_show_articles_by_tag_with_alternate_layout
    sites(:first).update_attribute :tag_layout, 'alt_layout.liquid'
    dispatch "tags"
    assert_dispatch_action :tags
    assert_preferred_template :tag
    assert_layout_template    :alt_layout
    assert_template_type      :tag
  end

  protected
    def dispatch(path = '', options = {})
      path = path[1..-1] if path.starts_with('/')
      send(options.delete(:method) || :get, :dispatch, options.merge(:path => path.split('/')))
    end

    def assert_preferred_template(expected)
      assert_equal "#{expected}.liquid", assigns(:site).recent_preferred_template.basename.to_s
    end
    
    def assert_layout_template(expected)
      assert_equal "#{expected}.liquid", assigns(:site).recent_layout_template.basename.to_s
    end
    
    def assert_template_type(expected)
      assert_equal expected, assigns(:site).recent_template_type
    end
    
    def assert_dispatch_action(expected)
      assert_equal expected, assigns(:dispatch_action), "Dispatch action didn't match: #{assigns(:dispatch_path).inspect}"
    end
end
