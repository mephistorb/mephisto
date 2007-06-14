require File.dirname(__FILE__) + '/../test_helper'

class EventTest < Test::Unit::TestCase
  fixtures :events, :contents, :users, :sites

  def setup
    [ArticleObserver, CommentObserver, ArticleSweeper, CommentSweeper].each &:instance
  end

  def test_should_create_new_article_event
    assert_event_created 'publish' do
      article = users(:quentin).articles.create :title => 'foo', :body => 'bar', :updater => users(:quentin), :site => sites(:first)
      article.events.first
    end
  end

  def test_should_create_edit_article_event
    assert_difference Event, :count do
      assert_event_created_for :welcome, 'edit' do |article|
        article.update_attributes :title => 'foo', :body => 'bar', :updater => users(:quentin), :filter => 'markdown_filter'
      end
    end
  end

  def test_should_should_require_title_or_body_for_edit_article_event
    assert_no_event_created do
      contents(:welcome).update_attributes :body_html => 'bar', :updater => users(:quentin)
    end
  end

  def test_should_not_create_article_event_for_save_without_revision
    assert_no_event_created do
      article = contents(:welcome)
      article.body = 'bar.'
      article.save_without_revision!
    end
  end

  def test_should_not_create_comment_article_event_for_unnaproved
    assert_no_event_created do
      contents(:welcome).comments.create :body => 'test comment', :author => 'bob', :author_ip => '127.0.0.1'
    end
  end

  def test_should_create_comment_article_event
    assert_event_created_for :welcome, 'comment' do |article|
      article.comments.create :body => 'test comment', :author => 'approved bob', :author_ip => '127.0.0.1'
    end
  end

  def test_should_delete_event_when_deleting_comment
    assert_difference Event, :count, -1 do
      contents(:unwelcome_comment).destroy
    end
  end
end
