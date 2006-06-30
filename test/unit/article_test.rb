require File.dirname(__FILE__) + '/../test_helper'

class ArticleTest < Test::Unit::TestCase
  fixtures :contents, :users, :sections, :sites

  def test_should_create_permalink
    a = Article.create :title => 'This IS a Tripped out title!!!1  (well not really)', :body => 'foo', :user_id => 1, :site_id => 1
    assert_equal 'this-is-a-tripped-out-title-1-well-not-really', a.permalink
  end

  def test_full_permalink
    date = 3.days.ago
    assert_equal ['', date.year, date.month, date.day, 'welcome-to-mephisto'].join('/'), contents(:welcome).full_permalink
  end

  def test_should_show_published_status
    assert contents(:welcome).published?
    assert contents(:future).published?
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
    assert_equal '<p><strong>foo</strong></p>', a.excerpt_html
    assert_equal '<p><em>bar</em></p>',         a.body_html
  end

  def test_should_save_filters_from_user
    a = Article.create :title => 'This IS a Tripped out title!!!1  (well not really)', :user => users(:quentin), :excerpt => '*foo*', :body => '_bar_', :site_id => 1
    assert_equal :textile_filter, a.filters.first
  end

  def test_should_cache_bluecloth
    a = Article.create :title => 'simple Title', :user => users(:arthur), :body => "# bar\n\nfoo", :filters => [:markdown_filter], :site_id => 1
    assert_equal "<h1>bar</h1>\n\n<p>foo</p>", a.body_html
  end

  def test_should_create_article_version
    assert_difference Article::Version, :count, 2 do
      Article.create :title => 'This IS a Tripped out title!!!1  (well not really)', :body => 'foo', :user_id => 1, :site_id => 1
      contents(:welcome).update_attributes :title => 'whoo!'
    end
  end

  def test_should_not_create_article_version_for_useless_changes
    assert_no_difference Article::Version, :count do
      contents(:welcome).update_attributes :body_html => 'nope'
    end
  end
  
  def test_should_set_comment_expiration
    article = Article.new(:title => 'bar', :body => 'blah', :user_id => 1, :published_at => Time.now.utc, :site_id => 1)
    assert article.valid?, article.errors.full_messages.to_sentence
    assert_equal (article.published_at + 30.days), article.expire_comments_at
  end

  def test_should_set_explicit_comment_expiration
    date = 5.minutes.from_now
    article = Article.new(:title => 'bar', :body => 'blah', :user_id => 1, :published_at => Time.now.utc, :site_id => 1, :expire_comments_at => date)
    assert article.valid?, article.errors.full_messages.to_sentence
    assert_equal date, article.expire_comments_at
  end
  
  def test_should_turn_off_comments
    sites(:first).update_attributes(:accept_comments => false)
    article = Article.new(:title => 'bar', :body => 'blah', :user_id => 1, :published_at => Time.now.utc, :site_id => 1)
    assert article.valid?, article.errors.full_messages.to_sentence
    assert_equal article.published_at, article.expire_comments_at
  end

  def test_should_set_no_comment_expiration
    sites(:first).update_attributes(:comment_age => 0)
    article = Article.new(:title => 'bar', :body => 'blah', :user_id => 1, :published_at => Time.now.utc, :site_id => 1)
    assert article.valid?, article.errors.full_messages.to_sentence
    assert_nil article.expire_comments_at
  end
  
  def test_comment_expiry
    a = Article.new :expire_comments_at => 5.minutes.from_now.utc, :published_at => 5.minutes.from_now.utc
    assert !a.comments_allowed?
    a.published_at = 5.minutes.ago.utc
    assert  a.comments_allowed?
    a.expire_comments_at = 5.minutes.ago.utc
    assert !a.comments_allowed?
  end
end
