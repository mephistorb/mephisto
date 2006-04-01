require File.dirname(__FILE__) + '/../test_helper'

class EventTest < Test::Unit::TestCase
  fixtures :events, :contents, :users, :content_drafts

  def setup
    ArticleSweeper.instance
    CommentSweeper.instance
  end

  def test_should_create_new_article_event
    assert_event_created 'publish' do
      article = users(:quentin).articles.create :title => 'foo', :body => 'bar', :updater => users(:quentin)
      article.events.first
    end
  end

  def test_should_create_edit_article_event
    assert_event_created_for :welcome, 'edit' do |article|
      article.update_attributes :title => 'foo', :body => 'bar', :updater => users(:quentin)
    end
  end

  def test_should_should_require_title_or_body_for_edit_article_event
    assert_no_event_created do
      contents(:welcome).update_attributes :body_html => 'bar', :updater => users(:quentin)
    end
  end

  def test_should_create_comment_article_event
    assert_event_created_for :welcome, 'comment' do |article|
      article.comments.create :body => 'test comment', :author => 'bob', :author_ip => '127.0.0.1'
    end
  end
end
