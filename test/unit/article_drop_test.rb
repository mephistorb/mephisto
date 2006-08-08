require File.dirname(__FILE__) + '/../test_helper'

class ArticleDropTest < Test::Unit::TestCase
  fixtures :sites, :sections, :contents, :assigned_sections, :users
  
  def setup
    @article = Mephisto::Liquid::ArticleDrop.new(contents(:welcome), :single)
  end
  
  def test_should_convert_article_to_drop
    assert_kind_of Liquid::Drop, contents(:welcome).to_liquid
  end
  
  def test_should_list_all_but_home_sections
    assert_equal [sections(:about)], @article.sections.collect(&:section)
  end
  
  def test_should_list_only_blog_sections
    sections(:home).update_attribute :path, 'foo'
    assert_equal [sections(:home)], @article.blog_sections.collect(&:section)
  end
  
  def test_should_list_only_paged_sections
    assert_equal [sections(:about)], @article.page_sections.collect(&:section)
  end
end
