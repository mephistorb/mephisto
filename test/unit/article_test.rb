require File.dirname(__FILE__) + '/../test_helper'

class ArticleTest < Test::Unit::TestCase
  fixtures :contents, :users, :sections, :sites, :assigned_sections

  def test_find_next
    assert_equal contents(:another).next, contents(:site_map)
    assert_equal contents(:another).next(sections(:home)), contents(:welcome)
    assert_equal contents(:cupcake_welcome).next(sections(:cupcake_home)), nil
  end

  def test_should_find_previous
    assert_equal contents(:another).previous, contents(:at_beginning_of_next_month)
    assert_equal contents(:another).previous(sections(:home)), nil
    assert_not_equal contents(:another).previous(sections(:cupcake_home)), contents(:at_beginning_of_next_month)
  end
  
  def test_should_create_permalink
    a = create_article :title => 'This IS a Tripped out title!!.!1  (well/ not really)', :body => 'foo'
    assert_equal 'this-is-a-tripped-out-title-1-well-not-really', a.permalink
  end

  def test_should_set_permalink
    a = create_article :title => 'This IS a Tripped out title!!.!1  (well/ not really)', :body => 'foo', :permalink => 'trippy'
    assert_equal 'trippy', a.permalink
  end
  
  def test_permalink_for_strange_article_title
    title = '////// meph1sto r0x ! \\\\\\'
    assert_equal 'meph1sto-r0x', Article.permalink_for(title)
  end
  
  def test_permalink_with_non_ascii_chars
    assert_equal 'acegiklnu', Article.permalink_for('āčēģīķļņū')
  end

  def test_should_pass_changed_attributes_down_to_comments
    contents(:welcome).update_attributes(:title => 'foo bar', :published_at => Time.utc(2000, 1, 1), :permalink => 'foo-bar')
    assert_equal 'foo bar', contents(:welcome_comment).title
    assert_equal Time.utc(2000, 1, 1), contents(:welcome_comment).published_at
    assert_equal 'foo-bar', contents(:welcome_comment).permalink
  end

  def test_full_permalink
    date = 3.days.ago.utc
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
    assert_equal '<p><strong>foo</strong></p>', a.excerpt_html
    assert_equal '<p><em>bar</em></p>',         a.body_html
  end

  def test_should_save_filter_from_user
    a = Article.new
    assert_nil a.filter
    a.set_default_filter_from(users(:quentin))
    assert_equal 'textile_filter', a.filter
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

  def test_comment_expiration_date_on_draft
    a = create_fake_article
    a.published_at = nil
    assert_equal 10.days.from_now.utc.to_i, a.comments_expired_at.to_i
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

  def test_should_set_published_to_utc
    a = create_article :body => 'body', :published_at => Time.now
    assert a.published_at.utc?
  end

  def test_should_find_deleted_user
    assert_equal User.find_with_deleted(3), contents(:another).user
  end

  def test_should_set_tags
    assert_equal '', contents(:welcome).tag
    assert_difference Tagging, :count, 2 do
      contents(:welcome).update_attribute :tag, 'ruby, rails'
    end
    assert_equal 'rails, ruby', contents(:welcome).reload.tag
  end

  def test_should_set_tags_upon_article_creation
    a = nil
    assert_difference Tagging, :count, 2 do
      a = create_article :tag => 'ruby, rails', :body => 'foo'
      assert_valid a
    end
    assert_equal 'rails, ruby', a.reload.tag
  end

  def test_should_find_article_by_permalink
    assert_equal contents(:welcome), sites(:first).articles.find_by_permalink(:id => contents(:welcome).id)
    assert_equal contents(:welcome), sites(:first).articles.find_by_permalink(:permalink => contents(:welcome).permalink)
    assert_equal contents(:welcome), sites(:first).articles.find_by_permalink(:year => contents(:welcome).year, :permalink => contents(:welcome).permalink)
  end

  def test_should_find_all_in_month
    two_months_ago = Time.now.utc.advance(:months => -2)
    articles = Article.find_all_in_month(two_months_ago.year, two_months_ago.month)

    assert_equal 3, articles.length
    [:at_beginning_of_month, :at_end_of_month, :at_middle_of_month].each do |article|
      assert articles.include?(contents(article))
    end
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

class ArticleFilterEditTest < Test::Unit::TestCase
  fixtures :contents, :users, :sections, :sites

  def setup
    @old_time = contents(:welcome_comment).updated_at
    assert_equal 'textile_filter', contents(:welcome).filter
    contents(:welcome).filter = 'markdown_filter'
    contents(:welcome).save!
  end

  def test_should_clear_filter
    contents(:welcome).filter = ''
    contents(:welcome).save!
    assert_equal '', contents(:welcome).filter
  end

  def test_should_modify_filter
    assert_equal 'markdown_filter', contents(:welcome).reload.filter
  end

  def test_should_modify_filter_and_leave_comments_alone
    assert_equal 'textile_filter', contents(:welcome_comment).reload.filter
  end

  def test_should_modify_filter_and_not_modify_comment_timestamps
    assert_equal @old_time, contents(:welcome_comment).reload.updated_at
  end
end
