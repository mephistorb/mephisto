require File.dirname(__FILE__) + '/../test_helper'

class EventTest < Test::Unit::TestCase
  fixtures :events, :contents, :users

  def setup
    ArticleObserver.instance
  end

  def test_should_create_new_article_event
    assert_event_created 'create' do
      article = users(:quentin).articles.create :title => 'foo', :body => 'bar', :updater => users(:quentin)
      article.events.first
    end
  end

  def test_should_create_edit_article_event
    assert_event_created_for :welcome, 'edit' do |article|
      article.update_attributes :title => 'foo', :body => 'bar', :updater => users(:quentin)
    end
  end

  def test_should_create_published_article_event
    assert_event_created_for :unpublished, 'publish' do |article|
      article.update_attributes :published_at => 5.minutes.ago, :updater => users(:quentin)
    end
  end

  def test_should_should_require_title_or_body_for_edit_article_event
    assert_no_event_created do
      contents(:welcome).update_attributes :body_html => 'bar', :updater => users(:quentin)
    end
  end
end
