require File.dirname(__FILE__) + '/../test_helper'

class TagTest < Test::Unit::TestCase
  fixtures :tags, :articles, :taggings

  def test_find_or_create_sanity
    assert_equal tags(:home), Tag.find_or_create_by_name('home')
    assert_equal 3, Tag.find_or_create_by_name('foo').id
  end

  def test_articles_association_by_published_at
    assert_equal [articles(:another), articles(:welcome)], tags(:home).articles.find_by_date
  end

  def test_articles_association_by_position
    assert_equal [articles(:welcome), articles(:another)], tags(:home).articles.find_by_position
  end
end
