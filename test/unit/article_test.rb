require File.dirname(__FILE__) + '/../test_helper'

class ArticleTest < Test::Unit::TestCase
  fixtures :articles

  def test_should_create_permalink
    a = Article.create :title => 'This IS a Tripped out title!!!1  (well not really)', :user_id => 1
    assert_equal 'this_is_a_tripped_out_title_1_well_not_really', a.permalink
  end

  def test_full_permalink
    date = 3.days.ago
    assert_equal ['', date.year, date.month, date.day, 'welcome_to_mephisto'].join('/'), articles(:welcome).full_permalink
  end

  def test_should_show_published_status
    assert articles(:welcome).published?
    assert articles(:future).published?
    assert !articles(:unpublished).published?
  end

  def test_should_show_pending_status
    assert !articles(:welcome).pending?
    assert articles(:future).pending?
    assert !articles(:unpublished).pending?
  end

  def test_should_show_status
    assert_equal :published,   articles(:welcome).status
    assert_equal :pending,     articles(:future).status
    assert_equal :unpublished, articles(:unpublished).status
  end
end
