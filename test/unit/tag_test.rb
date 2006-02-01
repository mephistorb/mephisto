require File.dirname(__FILE__) + '/../test_helper'

class TagTest < Test::Unit::TestCase
  fixtures :tags, :articles, :taggings

  def test_find_or_create_sanity_check
    assert_no_difference Tag, :count do
      assert_equal tags(:home), Tag.find_or_create_by_name('home')
    end
    
    assert_difference Tag, :count do 
      Tag.find_or_create_by_name('foo')
    end
  end

  def test_articles_association_by_published_at
    assert_equal [articles(:welcome), articles(:another)], tags(:home).articles.find_by_date
  end

  def test_articles_association_by_position
    assert_equal articles(:welcome), tags(:home).articles.find_by_position
    assert_equal articles(:welcome), tags(:about).articles.find_by_position
  end

  def test_should_find_tagged_articles_by_permalink
    assert_equal articles(:welcome),  tags(:about).articles.find_by_permalink('welcome_to_mephisto')
    assert_equal articles(:site_map), tags(:about).articles.find_by_permalink('the_site_map')
    assert_equal nil,                 tags(:about).articles.find_by_permalink('another_welcome_to_mephisto')
  end

  def test_should_find_tag_with_permalink_extra
    assert_equal [tags(:about), nil],   Tag.find_tag_and_page_name(%w(about))
    assert_equal [tags(:about), 'foo'], Tag.find_tag_and_page_name(%w(about foo))
    assert_equal [nil, 'foo'],          Tag.find_tag_and_page_name(%w(foo))
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

  def test_should_create_correct_tag_url_hash
    assert_equal({ :tags => [] },        tags(:home).hash_for_url)
    assert_equal({ :tags => %w(about) }, tags(:about).hash_for_url)
  end

  def test_should_return_correct_tags
    assert_equal [tags(:home), tags(:about)], Tag.find(:all)
    assert_equal [tags(:about)], Tag.find_paged
  end

  def test_should_show_correct_titles
    tags(:about).name = 'about/foo'
    assert_equal 'Home', tags(:home).title
    assert_equal 'Foo',  tags(:about).title
  end
end
