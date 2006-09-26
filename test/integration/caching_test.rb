require File.dirname(__FILE__) + '/../test_helper'
class CachingTest < ActionController::IntegrationTest
  fixtures :contents, :users, :sections, :assigned_sections, :sites

  def setup
    prepare_for_caching!
    prepare_theme_fixtures
  end

  def test_should_expire_necessary_feeds_and_sections_when_publishing_article
    visitor = visit
    writer  = login_as :quentin
    
    visit_sections_and_feeds_with visitor

    assert_difference Article, :count do
      assert_expires_pages section_url_for(:home),
                           feed_url_for(:home) do
        writer.create :title => 'This is a new article & title', :body => 'this is a new article body', :sections => [sections(:home)], :published_at => 5.minutes.ago
      end
    end
    
    assert_cached section_url_for(:about)
    assert_cached feed_url_for(:about)
  end

  def test_should_expire_feeds_and_sections_when_publishing_article
    visitor = visit
    writer  = login_as :quentin
    
    visit_sections_and_feeds_with visitor

    assert_difference Article, :count do
      assert_expires_pages section_url_for(:home), section_url_for(:about),
                           feed_url_for(:home),    feed_url_for(:about) do
        writer.create :title => 'This is a new article & title', :body => 'this is a new article body', :sections => [sections(:home), sections(:about)], :published_at => Time.now
      end
    end
  end

  def test_should_expire_articles_after_editing
    visitor = visit
    writer  = login_as :quentin
    
    assert_caches_page contents(:welcome).full_permalink do
      visitor.read contents(:welcome)
    end

    assert_caches_page "#{contents(:welcome).full_permalink}/changes.xml" do |urls|
      visitor.get urls.first
    end

    assert_caches_page "#{contents(:welcome).full_permalink}/comments.xml" do |urls|
      visitor.get urls.first
    end

    assert_caches_page feed_url_for(:home) do
      visitor.syndicate sections(:home)
    end

    assert_expires_pages contents(:welcome).full_permalink, 
                         "#{contents(:welcome).full_permalink}/changes.xml",
                         "#{contents(:welcome).full_permalink}/comments.xml",
                         feed_url_for(:home) do
      writer.revise contents(:welcome), 'new welcome description'
    end
  end

  def test_should_cache_and_expire_overview_feed_on_edited_article
    rss     = visit
    writer  = login_as :quentin

    assert_caches_page overview_path do
      rss.get_with_basic 'admin/overview.xml', :login => :quentin
    end

    assert_expires_page overview_path do
      writer.revise contents(:welcome), 'new welcome description'
    end
  end

  def test_should_not_expire_cache_on_new_comment
    visitor = visit
    assert_caches_page contents(:welcome).full_permalink do
      visitor.read contents(:welcome)
    end
    
    visitor.comment_on contents(:welcome), :author => 'bob', :body => 'what a wonderful post.'
    
    assert_cached contents(:welcome).full_permalink
  end

  def test_should_not_cache_comment_post
    visitor = visit
    assert_expires_pages "#{contents(:welcome).full_permalink}/comments" do
      visitor.comment_on contents(:welcome), :author => 'bob', :body => 'what a wonderful post.'
    end
  end

  def test_should_not_cache_comment_post_on_article_with_closed_comments
    visitor = visit
    contents(:welcome).update_attribute :comment_age, -1
    assert_expires_pages "#{contents(:welcome).full_permalink}/comments" do
      visitor.comment_on contents(:welcome), :author => 'bob', :body => 'what a wonderful post.'
    end
  end

  def test_should_not_cache_comment_post_on_article_with_invalid_comment
    visitor = visit
    assert_expires_pages "#{contents(:welcome).full_permalink}/comments" do
      assert_no_difference Comment, :count do
        visitor.comment_on contents(:welcome), {}
      end
    end
  end

  def test_should_not_cache_comments_page_on_get
    visitor = visit
    assert_expires_pages "#{contents(:welcome).full_permalink}/comments" do
      visitor.get "#{contents(:welcome).full_permalink}/comments"
    end
  end

  def test_should_expire_cache_on_new_comment_if_approved
    visitor = visit
    assert_caches_page contents(:welcome).full_permalink do
      visitor.read contents(:welcome)
    end
    
    assert_caches_page "/feed/comments.xml", "/feed/all_comments.xml" do |urls|
      urls.each { |u| visitor.get u }
    end
    
    assert_expires_pages contents(:welcome).full_permalink, "/feed/comments.xml", "/feed/all_comments.xml" do
      visitor.comment_on contents(:welcome), :author => 'approved bob', :body => 'what a wonderful post.'
    end
  end

  def test_should_expire_cache_when_comment_is_approved
    visitor = visit
    assert_caches_page contents(:welcome).full_permalink do
      visitor.read contents(:welcome)
    end

    login_as :quentin do |writer|
      writer.approve_comment contents(:unwelcome_comment)
      assert contents(:unwelcome_comment).reload.approved?
    end

    assert_not_cached contents(:welcome).full_permalink
  end

  def test_should_expire_cache_when_comment_is_unapproved
    visitor = visit
    assert_caches_page contents(:welcome).full_permalink do
      visitor.read contents(:welcome)
    end

    login_as :quentin do |writer|
      writer.unapprove_comment contents(:welcome_comment)
      assert !contents(:welcome_comment).reload.approved?
    end

    assert_not_cached contents(:welcome).full_permalink
  end

  def test_should_expire_cache_when_approved_comment_is_deleted
    visitor = visit
    rss     = visit
    writer  = login_as :quentin
    assert_caches_page contents(:welcome).full_permalink do
      visitor.read contents(:welcome)
    end
    
    assert_caches_page overview_path do
      rss.get_with_basic 'admin/overview.xml', :login => :quentin
    end

    assert_expires_pages overview_path, contents(:welcome).full_permalink do
      writer.post "admin/articles/destroy_comment/#{contents(:welcome).id}", :comment => contents(:welcome_comment).id
    end
  end

  def test_should_only_expire_overview_when_unapproved_comment_is_deleted
    visitor = visit
    rss     = visit
    writer  = login_as :quentin
    assert_caches_page contents(:welcome).full_permalink do
      visitor.read contents(:welcome)
    end

    assert_caches_page overview_path do
      rss.get_with_basic 'admin/overview.xml', :login => :quentin
    end

    assert_expires_pages overview_path do
      contents(:welcome_comment).update_attribute :approved, false
      writer.post "admin/articles/destroy_comment/#{contents(:welcome).id}", :comment => contents(:welcome_comment).id
    end

    assert_cached contents(:welcome).full_permalink
  end

  def test_should_not_cache_bad_urls
    visitor = visit
    pages   = ['/about/blah', '/foo/bar', '2006/1/2/fasd']
    assert_no_difference CachedPage, :count do
      assert_expires_pages *pages do
        pages.each { |p| visitor.get p }
      end
    end
  end

  def test_should_expire_section_cache_when_updating_section
    visitor = visit
    assert_caches_page section_url_for(:about) do
      visitor.read sections(:about)
    end
    
    assert_caches_page feed_url_for(:about) do
      visitor.syndicate sections(:about)
    end
    
    assert_caches_page section_url_for(:about, :site_map) do
      visitor.read_page sections(:about), contents(:site_map)
    end
    
    assert_expires_pages section_url_for(:about), feed_url_for(:about), section_url_for(:about, :site_map) do
      login_as :quentin do |writer|
        writer.update_section sections(:about), :name => 'ABOUT'
      end
    end
  end

  def test_should_expire_cache_when_updating_template
    visit_sections_and_feeds_with visit
    assert_expires_pages section_url_for(:home), section_url_for(:about), feed_url_for(:home), feed_url_for(:about) do
      login_as :quentin do |writer|
        writer.update_template sites(:first).templates[:error], '<p>error!</p>'
      end
    end
  end

  def test_should_expire_new_assigned_section_to_article
    visitor = visit
    writer  = login_as :quentin
    visit_sections_and_feeds_with visitor
    assert_expires_pages feed_url_for(:about) do
      writer.revise contents(:site_map), 'sitemap whoo'
    end
    
    assert_cached section_url_for(:about) # paged section only shows the homepage
    assert_cached section_url_for(:home)
    assert_cached feed_url_for(:home)

    assert_expires_pages section_url_for(:home), feed_url_for(:home), feed_url_for(:about) do
      writer.revise contents(:site_map), :sections => [sections(:home), sections(:about)]
    end
  end

  def test_should_expire_section_when_removing_from_article
    visit_sections_and_feeds_with visit
    assert_expires_pages section_url_for(:home), section_url_for(:about), feed_url_for(:home), feed_url_for(:about) do
      login_as :quentin do |writer|
        writer.revise contents(:site_map), :sections => [sections(:home)]
      end
    end
  end

  def test_should_expire_section_and_article_cache_when_deleting_article
    visitor = visit
    
    visit_sections_and_feeds_with visitor
    visitor.read contents(:site_map)
    
    assert_expires_pages feed_url_for(:about), section_url_for(:about), contents(:site_map).full_permalink do
      login_as :quentin do |writer|
        writer.remove_article contents(:site_map)
      end
    end

    assert_cached section_url_for(:home)
    assert_cached feed_url_for(:home)
  end

  def test_should_expire_resource
    visitor = visit
    assert_caches_page '/images/rails-logo.png' do
      visitor.read '/images/rails-logo.png'
    end
    
    assert_expires_page 'images/rails-logo.png' do
      login_as :quentin do |writer|
        writer.update_resource sites(:first).resources['rails-logo.png'], 'foo'
      end
    end
  end

  def test_should_not_cache_searches
    visitor = visit
    assert_expires_page "/search" do
      visitor.get  '/search'
      visitor.get  '/search', :q => 'foo'
      visitor.post '/search', :q => 'foo'
    end
  end

  protected
    def visit_sections_and_feeds_with(visitor)
      assert_difference CachedPage, :count, 4 do
        assert_caches_page section_url_for(:home) do
          visitor.read sections(:home)
        end
        
        assert_caches_page section_url_for(:about) do
          visitor.read sections(:about)
        end
        
        assert_caches_page feed_url_for(:home) do
          visitor.syndicate sections(:home)
        end
        
        assert_caches_page feed_url_for(:about) do
          visitor.syndicate sections(:about)
        end
      end
    end
end