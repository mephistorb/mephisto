require File.dirname(__FILE__) + '/../test_helper'

class ArticleTest < Test::Unit::TestCase
  fixtures :contents, :users, :sections, :sites

  def test_should_create_permalink
    a = create_article :title => 'This IS a Tripped out title!!.!1  (well/ not really)', :body => 'foo'
    assert_equal 'this-is-a-tripped-out-title-1-well-not-really', a.permalink
  end

  def test_full_permalink
    date = 3.days.ago
    assert_equal ['', date.year, date.month, date.day, 'welcome-to-mephisto'].join('/'), contents(:welcome).full_permalink
  end

  def test_should_show_published_status
    assert !Article.new(:published_at => 5.minutes.ago).published?
    assert  contents(:welcome).published?
    assert  contents(:future).published?
  end

  def test_should_show_pending_status
    assert !contents(:welcome).pending?
    assert contents(:future).pending?
  end

  def test_should_show_status
    assert_equal :published, contents(:welcome).status
    assert_equal :pending,   contents(:future).status
  end

  def test_should_cache_redcloth
    a = Article.create :title => 'This IS a Tripped out title!!!1  (well not really)', :user => users(:quentin), :excerpt => '*foo*', :body => '_bar_', :site_id => 1
    assert_equal '<p><strong>foo</strong></p>',    a.excerpt_html
    assert_equal '<p><em>bar</em></p>',            a.body_html
  end

  def test_should_save_filter_from_user
    a = Article.new
    assert_nil a.filter
    a.set_default_filter_from(users(:quentin))
    assert_equal 'textile_filter', a.filter
  end

  def test_should_modify_filter
    assert_equal 'textile_filter', contents(:welcome).filter
    assert_equal 'textile_filter', contents(:welcome_comment).filter
    
    contents(:welcome).filter = 'markdown_filter'
    contents(:welcome).save

    assert_equal 'markdown_filter', contents(:welcome).reload.filter
    assert_equal 'markdown_filter', contents(:welcome_comment).reload.filter
  end

  def test_should_cache_bluecloth
    a = Article.create :title => 'simple Title', :user => users(:arthur), :body => "# bar\n\nfoo", :filter => 'markdown_filter', :site_id => 1
    assert_equal "<h1>bar</h1>\n\n<p>foo</p>", a.body_html
  end

  def test_should_create_article_version
    assert_difference Article::Version, :count, 2 do
      Article.create :title => 'This IS a Tripped out title!!!1  (well not really)', :body => 'foo', :user_id => 1, :site_id => 1
      contents(:welcome).update_attributes :title => 'whoo!'
    end
  end

  def test_should_not_create_article_version_for_useless_changes
    contents(:welcome).body_html = 'nope'
    assert !contents(:welcome).save_version?
  end

  def test_comment_expiration_date
    a = create_fake_article
    assert_equal 5.days.from_now.utc.to_i, a.comments_expired_at.to_i
  end

  def test_comment_expiry
    a = create_fake_article(5.days.from_now)
    assert !a.accept_comments?
    a.published_at = 5.days.ago.utc
    assert  a.accept_comments?
    a.comment_age = 2
    assert !a.accept_comments?
    a.published_at = 5.years.ago.utc
    assert !a.accept_comments?
    a.comment_age = 0
    assert  a.accept_comments?
  end

  def test_empty_body
    a = create_article
    assert_equal '', a.send(:body_for_mode, :single)
    assert_equal '', a.send(:body_for_mode, :list)
  end
  
  def test_body_with_excerpt
    a = create_article :excerpt => 'excerpt', :body => 'body'
    assert_equal "<p>body</p>", a.send(:body_for_mode, :single)
    assert_equal '<p>excerpt</p>', a.send(:body_for_mode, :list)
  end
  
  def test_only_body
    a = create_article :body => 'body'
    assert_equal "<p>body</p>", a.send(:body_for_mode, :single)
    assert_equal '<p>body</p>', a.send(:body_for_mode, :list)
  end
  
  def test_only_body_with_empty_excerpt
    a = create_article :body => 'body', :excerpt => ''
    assert_equal "<p>body</p>", a.send(:body_for_mode, :single)
    assert_equal '<p>body</p>', a.send(:body_for_mode, :list)
  end

  def test_should_set_published_to_utc
    a = create_article :body => 'body', :published_at => Time.now
    assert a.published_at.utc?
  end

  def test_should_find_deleted_user
    assert_equal User.find_with_deleted(3), contents(:another).user
  end

  protected
    def create_article(options = {})
      Article.create options.reverse_merge(:user_id => 1, :site_id => 1, :title => 'foo')
    end
    
    def create_fake_article(time = 5.days.ago)
      returning Article.new(:comment_age => 10, :published_at => time.utc) do |a|
        def a.new_record?() false ; end
      end
    end
end
