require File.dirname(__FILE__) + '/../test_helper'

# Re-raise errors caught by the controller.
class FeedController; def rescue_action(e) raise e end; end

class FeedControllerTest < Test::Unit::TestCase
  fixtures :contents, :sections, :assigned_sections, :sites
  
  def setup
    @controller = FeedController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end
  
  def test_feed_comes_from_site
    host! 'cupcake.com'
    get :feed, :sections => ['about']
    assert_equal sections(:cupcake_about), assigns(:section)
    assert_equal [contents(:cupcake_welcome)], assigns(:articles)
    assert_atom_entries_size 1
  end
  
  def test_site_in_feed_links
    host! 'cupcake.com'
    get :feed, :sections => []
    assert_models_equal [sections(:cupcake_home)], [assigns(:section)]
    assert_models_equal [contents(:cupcake_welcome)], assigns(:articles)
    assert_atom_entries_size 1
    assert_select 'link[href=?]', 'http://cupcake.com/'
  end
  
  def test_should_return_record_not_found_for_bad_feed_urls
    get :feed, :sections => %w(beastie boys)
    assert_equal '404', @response.code
  end
  
  def test_should_find_comments_by_site
    get :feed, :sections => %w(all_comments.xml)
    assert_select 'feed>title', 'Mephisto - All Comments'
    assert_nil assigns(:section)
    assert_models_equal [contents(:welcome_comment)], assigns(:comments)
    assert_atom_entries_size 1
  end
  
  def test_should_find_comments_by_section
    get :feed, :sections => %w(comments.xml)
    assert_select 'feed>title', 'Mephisto - Home Comments'
    assert_models_equal [sections(:home)], [assigns(:section)]
    assert_models_equal [contents(:welcome_comment)], assigns(:comments)
    assert_atom_entries_size 1
  end
end

context "About Section Feed" do
  fixtures :contents, :sections, :assigned_sections, :sites, :users, :assets, :assigned_assets
  def setup
    @controller = FeedController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    get :feed, :sections => ['about']
  end

  specify "should select correct records" do
    assert_equal sections(:about), assigns(:section)
    assert_equal [contents(:welcome), contents(:about), contents(:site_map)], assigns(:articles)
  end
  
  specify "should show correct titles" do
    assert_select 'feed>title', 'Mephisto - About'
    assert_select 'feed>entry>title', 3 do |titles|
      assert_equal 'Welcome to Mephisto', titles[0].children.first.content
      assert_equal 'About this page',     titles[1].children.first.content
      assert_equal 'The Site Map',        titles[2].children.first.content
    end
  end
  
  specify "should show correct links" do
    assert_select 'feed>link[href=?][type=?]', 'http://test.host/about', 'text/html'
    assert_select 'feed>entry>link[href]', 4 do |hrefs|
      assert_equal "http://test.host/about",                 hrefs[0]['href']
      assert_match /asset\.mp3$/,                            hrefs[1]['href']
      assert_equal "http://test.host/about/about-this-page", hrefs[2]['href']
      assert_equal "http://test.host/about/the-site-map",    hrefs[3]['href']
    end
  end
end

context "Home Section Feed" do
  fixtures :contents, :sections, :assigned_sections, :sites, :assets, :assigned_assets
  def setup
    @controller = FeedController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    get :feed, :sections => []
    @contents = get_xpath '//entry/content'
  end
  
  specify "should show titles" do
    assert_select 'feed>title', 'Mephisto - Home'
    assert_select 'feed>entry>title', 2 do |elements|
      assert_equal 'Welcome to Mephisto',         elements[0].children.first.content
      assert_equal 'Another Welcome to Mephisto', elements[1].children.first.content
    end
  end
  
  specify "should show correct links" do
    assert_select 'feed>link[href=?][type=?]', 'http://test.host/', 'text/html'
    assert_select 'feed>entry>link[href]', 3 do |hrefs|
      assert_match /\/welcome-to-mephisto$/,         hrefs[0]['href']
      assert_match /asset\.mp3$/,                    hrefs[1]['href']
      assert_match /\/another-welcome-to-mephisto$/, hrefs[2]['href']
    end
  end

  specify "should show podcast" do
    assert_select 'feed>entry>link[rel=?][length=?][type=?]', 'enclosure', '252366', 'audio/mpeg'
  end

  specify "show absolute urls with custom relative url root" do
    begin
      old_root = ActionController::Base.relative_url_root
      ActionController::Base.relative_url_root = '/weblog'
      get :feed, :sections => []
      assert_select 'feed entry link' do
        assert_select '[href=?]', /^http\:\/\/test\.host\/weblog\/\d{4}\/.*$/
      end
    ensure
      ActionController::Base.relative_url_root = old_root
    end
  end

  specify "should not double escape html" do
    text = @contents.first.get_text.to_s.strip
    assert text.starts_with("welcome summary\n&lt;p&gt;quentin&#8217;s &#8220;welcome&#8221;"), "'#{text.inspect}' was double escaped"
  end
  
  specify "should sanitize content" do
    text = @contents.first.get_text.to_s.strip
    evil = "<script>hi</script><a onclick=\"foo\" href=\"#\">linkage</a></p>"
    good = %(<a href="#">linkage</a></p>)
    assert !text.ends_with(CGI::escapeHTML(evil)), "'#{text.inspect}' was not sanitized"
    assert  text.ends_with(CGI::escapeHTML(good)), "'#{text.inspect}' was not sanitized"
  end
end
