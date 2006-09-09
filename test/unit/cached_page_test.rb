require File.dirname(__FILE__) + '/../test_helper'

class CachedPageTest < Test::Unit::TestCase
  fixtures :contents, :sites, :cached_pages
  
  def test_should_find_by_references
    assert_models_equal [cached_pages(:first)], sites(:first).cached_pages.find_by_references(contents(:welcome))
  end

  def test_should_find_by_reference_keys
    assert_models_equal [cached_pages(:first)], sites(:first).cached_pages.find_by_reference_keys(['Article', 1])
  end

  def test_should_find_by_reference_key
    assert_models_equal [cached_pages(:first)], sites(:first).cached_pages.find_by_reference_key('Article', 1)
  end
  
  def test_should_create_cached_page
    assert_difference CachedPage, :count do
      assert_difference sites(:first).cached_pages, :count do
        page = CachedPage.create_by_url(sites(:first), '/blah', [contents(:welcome)])
        assert_valid page
        assert_equal '/blah', page.url
        assert_equal "[1:Article]", page.references
      end
    end
  end
  
  def test_should_create_cached_page_from_existing_record
    assert_no_difference CachedPage, :count do
      assert_no_difference sites(:first).cached_pages, :count do
        page = CachedPage.create_by_url(sites(:first), '/bar', [contents(:welcome)])
        assert_valid page
        assert_equal '/bar', page.url
        assert_equal "[1:Article]", page.references
        assert_equal cached_pages(:first_cleared), page
        assert_nil page.cleared_at
      end
    end
  end
  
  def test_should_expire_sites
    assert_no_difference CachedPage, :count do
      assert_no_difference sites(:first).cached_pages, :count do
        CachedPage.expire_pages(sites(:first), [cached_pages(:first)])
        assert_not_nil cached_pages(:first).reload.cleared_at
      end
    end
  end
end
