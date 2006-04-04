require File.dirname(__FILE__) + '/../test_helper'

class SectionTest < Test::Unit::TestCase
  fixtures :sections, :contents, :assigned_sections, :sites

  def test_find_or_create_sanity_check
    assert_no_difference Section, :count do
      assert_equal sections(:home), Section.find_or_create_by_name('home')
    end
    
    assert_difference Section, :count do 
      Section.find_or_create_by_name('foo')
    end
  end

  def test_should_return_correct_url_paths
    assert_equal [],        sections(:home).to_url
    assert_equal ['about'], sections(:about).to_url
  end

  def test_should_return_correct_feed_url_paths
    assert_equal ['atom.xml'],          sections(:home).to_feed_url
    assert_equal ['about', 'atom.xml'], sections(:about).to_feed_url
  end

  def test_articles_association_by_published_at
    assert_equal [contents(:welcome), contents(:another)], sections(:home).articles.find_by_date
  end

  def test_articles_association_by_position
    assert_equal contents(:welcome), sections(:home).articles.find_by_position
    assert_equal contents(:welcome), sections(:about).articles.find_by_position
  end

  def test_should_find_categorized_articles_by_permalink
    assert_equal contents(:welcome),  sections(:about).articles.find_by_permalink('welcome-to-mephisto')
    assert_equal contents(:site_map), sections(:about).articles.find_by_permalink('the-site-map')
    assert_equal nil,                 sections(:about).articles.find_by_permalink('another-welcome-to-mephisto')
  end

  def test_should_find_section_with_permalink_extra
    assert_equal [sections(:about), nil],   Section.find_section_and_page_name(%w(about))
    assert_equal [sections(:about), 'foo'], Section.find_section_and_page_name(%w(about foo))
    assert_equal [nil, 'foo'],              Section.find_section_and_page_name(%w(foo))
  end

  def test_should_include_home_section_by_default
    a = Article.new
    assert a.has_section?(sections(:home))
    assert !a.has_section?(sections(:about))
  end

  def test_should_include_home_section_by_default
    assert contents(:welcome).has_section?(sections(:home))
    assert contents(:welcome).has_section?(sections(:about))
    assert !contents(:another).has_section?(sections(:about))
  end

  def test_should_create_article_with_sections
    a = Article.create :title => 'foo', :body => 'bar', :user_id => 1, :section_ids => [sections(:home).id, sections(:about).id]
    assert_equal [sections(:about), sections(:home)], a.sections
  end

  def test_should_update_article_with_sections
    assert_equal [sections(:about), sections(:home)], contents(:welcome).sections
    contents(:welcome).update_attribute :section_ids, [sections(:home).id]
    assert_equal [sections(:home)], contents(:welcome).sections(true)
  end

  def test_should_update_article_with_no_sections
    assert_equal [sections(:about), sections(:home)], contents(:welcome).sections
    contents(:welcome).update_attributes :section_ids => []
    assert_equal [], contents(:welcome).sections(true)
  end

  def test_should_create_correct_section_url_hash
    assert_equal({ :sections => [] },        sections(:home).hash_for_url)
    assert_equal({ :sections => %w(about) }, sections(:about).hash_for_url)
  end

  def test_should_return_correct_sections
    assert_equal [sections(:about), sections(:home)], sites(:first).sections.find(:all, :order => 'name')
    assert_equal [sections(:about)], sites(:first).sections.find_paged
  end

  def test_should_show_correct_titles
    sections(:about).name = 'about/foo'
    assert_equal 'Home', sections(:home).title
    assert_equal 'Foo',  sections(:about).title
  end

  def test_should_order_sections
    assert_reorder_articles sections(:about),
      [contents(:welcome), contents(:about), contents(:site_map)],
      [contents(:about), contents(:site_map), contents(:welcome)]
  end

  def assert_reorder_articles(section, old_order, expected)
    assert_equal old_order, section.articles
    section.order! expected.collect(&:id)
    assert_equal expected, section.articles(true)
  end
end
