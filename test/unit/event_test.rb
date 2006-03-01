require File.dirname(__FILE__) + '/../test_helper'

class EventTest < Test::Unit::TestCase
  fixtures :events, :contents, :users

  def setup
    ArticleObserver.instance
  end

  def test_should_create_new_article_event
    assert_difference Event, :count do
      article = users(:quentin).articles.create :title => 'foo', :body => 'bar'
      assert_equal 'foo',    article.events.first.title
      assert_equal 'bar',    article.events.first.body
      assert_equal 'create', article.events.first.mode
    end
  end
end
