require File.dirname(__FILE__) + '/../test_helper'

class SiteDropTest < Test::Unit::TestCase
  fixtures :sites, :sections
  
  def setup
    @site = Mephisto::Liquid::SiteDrop.new(sites(:first))
  end
  
  def test_should_list_all_sections
    assert_equal [sections(:home), sections(:about)], @site.sections.collect(&:section)
  end
  
  def test_should_list_only_blog_sections
    assert_equal [sections(:home)], @site.blog_sections.collect(&:section)
  end
  
  def test_should_list_only_paged_sections
    assert_equal [sections(:about)], @site.page_sections.collect(&:section)
  end
end
