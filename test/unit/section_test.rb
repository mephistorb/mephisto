require File.dirname(__FILE__) + '/../test_helper'

class CategoryTest < Test::Unit::TestCase
  fixtures :categories, :contents, :categorizations

  def test_find_or_create_sanity_check
    assert_no_difference Category, :count do
      assert_equal categories(:home), Category.find_or_create_by_name('home')
    end
    
    assert_difference Category, :count do 
      Category.find_or_create_by_name('foo')
    end
  end

  def test_articles_association_by_published_at
    assert_equal [contents(:welcome), contents(:another)], categories(:home).articles.find_by_date
  end

  def test_articles_association_by_position
    assert_equal contents(:welcome), categories(:home).articles.find_by_position
    assert_equal contents(:welcome), categories(:about).articles.find_by_position
  end

  def test_should_find_categorized_articles_by_permalink
    assert_equal contents(:welcome),  categories(:about).articles.find_by_permalink('welcome-to-mephisto')
    assert_equal contents(:site_map), categories(:about).articles.find_by_permalink('the-site-map')
    assert_equal nil,                 categories(:about).articles.find_by_permalink('another-welcome-to-mephisto')
  end

  def test_should_find_category_with_permalink_extra
    assert_equal [categories(:about), nil],   Category.find_category_and_page_name(%w(about))
    assert_equal [categories(:about), 'foo'], Category.find_category_and_page_name(%w(about foo))
    assert_equal [nil, 'foo'],                Category.find_category_and_page_name(%w(foo))
  end

  def test_should_include_home_category_by_default
    a = Article.new
    assert a.has_category?(categories(:home))
    assert !a.has_category?(categories(:about))
  end

  def test_should_include_home_category_by_default
    assert contents(:welcome).has_category?(categories(:home))
    assert contents(:welcome).has_category?(categories(:about))
    assert !contents(:another).has_category?(categories(:about))
  end

  def test_should_create_article_with_categories
    a = Article.create :title => 'foo', :body => 'bar', :user_id => 1, :category_ids => [categories(:home).id, categories(:about).id]
    assert_equal [categories(:about), categories(:home)], a.categories
  end

  def test_should_update_article_with_categories
    assert_equal [categories(:about), categories(:home)], contents(:welcome).categories
    contents(:welcome).update_attribute :category_ids, [categories(:home).id]
    assert_equal [categories(:home)], contents(:welcome).categories(true)
  end

  def test_should_update_article_with_no_categories
    assert_equal [categories(:about), categories(:home)], contents(:welcome).categories
    contents(:welcome).update_attribute :category_ids, []
    assert_equal [], contents(:welcome).categories(true)
  end

  def test_should_create_correct_category_url_hash
    assert_equal({ :categories => [] },        categories(:home).hash_for_url)
    assert_equal({ :categories => %w(about) }, categories(:about).hash_for_url)
  end

  def test_should_return_correct_categories
    assert_equal [categories(:about), categories(:home)], Category.find(:all, :order => 'name')
    assert_equal [categories(:about)], Category.find_paged
  end

  def test_should_show_correct_titles
    categories(:about).name = 'about/foo'
    assert_equal 'Home', categories(:home).title
    assert_equal 'Foo',  categories(:about).title
  end
end
