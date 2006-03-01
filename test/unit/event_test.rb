require File.dirname(__FILE__) + '/../test_helper'

class EventTest < Test::Unit::TestCase
  fixtures :events, :contents, :users

  def setup
    ArticleObserver.instance
  end

  def test_should_create_new_article_event
    assert_difference Event, :count do
      article = users(:quentin).articles.create :title => 'foo', :body => 'bar', :updater => users(:quentin)
      assert_equal 'foo',    article.events.first.title
      assert_equal 'bar',    article.events.first.body
      assert_equal 'create', article.events.first.mode
    end
  end

  def test_should_create_edit_article_event
    assert_difference Event, :count do
      contents(:welcome).update_attributes :title => 'foo', :body => 'bar', :updater => users(:quentin)
      contents(:welcome).reload
      assert_equal 'foo',  contents(:welcome).events.first.title
      assert_equal 'bar',  contents(:welcome).events.first.body
      assert_equal 'edit', contents(:welcome).events.first.mode
    end
  end

  def test_should_create_published_article_event
    assert_difference Event, :count do
      contents(:unpublished).update_attributes :published_at => 5.minutes.ago, :updater => users(:quentin)
      contents(:unpublished).reload
      assert_equal 'publish', contents(:unpublished).events.first.mode
    end
  end

  def test_should_should_require_title_or_body_for_edit_article_event
    assert_no_difference Event, :count do
      contents(:welcome).update_attributes :body_html => 'bar', :updater => users(:quentin)
    end
  end
end
