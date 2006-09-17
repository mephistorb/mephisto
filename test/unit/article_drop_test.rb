require File.dirname(__FILE__) + '/../test_helper'

class ArticleDropTest < Test::Unit::TestCase
  fixtures :sites, :sections, :contents, :assigned_sections, :users, :tags, :taggings
  
  def setup
    @article = contents(:welcome).to_liquid :mode => :single
  end

  def test_equality
    article = contents(:welcome).to_liquid
    assert_equal article, contents(:welcome)
    assert_equal article, contents(:welcome).to_liquid
  end

  def test_should_convert_article_to_drop
    assert_kind_of Liquid::Drop, contents(:welcome).to_liquid
  end
  
  def test_should_list_all_but_home_sections
    assert_equal [sections(:about)], @article.sections.collect(&:section)
  end
  
  def test_should_list_tags
    assert_equal %w(rails), ArticleDrop.new(contents(:another)).tags
  end
  
  def test_should_list_only_blog_sections
    sections(:home).update_attribute :path, 'foo'
    assert_equal [sections(:home)], @article.blog_sections.collect(&:section)
  end
  
  def test_should_list_only_paged_sections
    assert_equal [sections(:about)], @article.page_sections.collect(&:section)
  end

  def test_empty_body
    assert contents(:welcome).update_attributes(:body => nil, :excerpt => nil), contents(:welcome).errors.full_messages.to_sentence
    a = contents(:welcome).to_liquid
    assert_equal '', a.send(:body_for_mode, :single)
    assert_equal '', a.send(:body_for_mode, :list)
  end
  
  def test_body_with_excerpt
    assert contents(:welcome).update_attributes(:body => 'body', :excerpt => 'excerpt'), contents(:welcome).errors.full_messages.to_sentence
    a = contents(:welcome).to_liquid
    assert_equal "<p>body</p>", a.send(:body_for_mode, :single)
    assert_equal '<p>excerpt</p>', a.send(:body_for_mode, :list)
  end
  
  def test_only_body
    assert contents(:welcome).update_attributes(:body => 'body', :excerpt => nil), contents(:welcome).errors.full_messages.to_sentence
    a = contents(:welcome).to_liquid
    assert_equal "<p>body</p>", a.send(:body_for_mode, :single)
    assert_equal '<p>body</p>', a.send(:body_for_mode, :list)
  end
  
  def test_only_body_with_empty_excerpt
    assert contents(:welcome).update_attributes(:body => 'body', :excerpt => ''), contents(:welcome).errors.full_messages.to_sentence
    a = contents(:welcome).to_liquid
    assert_equal "<p>body</p>", a.send(:body_for_mode, :single)
    assert_equal '<p>body</p>', a.send(:body_for_mode, :list)
  end
end
