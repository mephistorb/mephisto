require File.dirname(__FILE__) + '/../test_helper'

class TagTest < Test::Unit::TestCase
  fixtures :tags, :articles, :taggings

  def test_find_or_create_sanity_check
    assert_equal tags(:home), Tag.find_or_create_by_name('home')
    assert_equal 3, Tag.find_or_create_by_name('foo').id
  end

  def test_articles_association_by_published_at
    assert_equal [articles(:another), articles(:welcome)], tags(:home).articles.find_by_date
  end

  def test_articles_association_by_position
    assert_equal [articles(:welcome), articles(:another)], tags(:home).articles.find_by_position
  end

  def test_should_create_article_with_tags
    a = Article.create :title => 'foo', :user_id => 1, :tag_ids => [tags(:home).id, tags(:about).id]
    assert_equal [tags(:home), tags(:about)], a.tags
  end

  def test_should_update_article_with_tags
    assert_equal [tags(:home), tags(:about)], articles(:welcome).tags
    articles(:welcome).update_attribute :tag_ids, [tags(:home).id]
    assert_equal [tags(:home)], articles(:welcome).tags(true)
  end

  def test_should_update_article_with_no_tags
    assert_equal [tags(:home), tags(:about)], articles(:welcome).tags
    articles(:welcome).update_attribute :tag_ids, []
    assert_equal [], articles(:welcome).tags(true)
  end
end
