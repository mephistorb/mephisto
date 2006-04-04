require File.dirname(__FILE__) + '/../test_helper'

class SiteTest < Test::Unit::TestCase
  fixtures :sites, :contents, :content_drafts, :attachments, :db_files
  set_fixture_class :content_drafts => Article::Draft

  # Replace this with your real tests.
  def test_truth
    assert_kind_of Site, sites(:first)
  end
  
  def test_valid_host
    assert_valid sites(:first)
    assert_equal true, Site.create(:host => sites(:first).host, :title => 'Copy').new_record?
  end
  
  def test_articles
    assert_equal contents(:welcome), sites(:first).articles.find(:first, :order => 'contents.id')
    assert_equal contents(:cupcake_welcome), sites(:hostess).articles.find(:first, :order => 'contents.id')
  end
  
  def test_find_host
    assert_equal sites(:first), Site.find_by_host('test.host')
    assert_equal sites(:hostess), Site.find_by_host('cupcake.host')
  end
  
  def test_find_drafts
    assert_equal [content_drafts(:first), content_drafts(:welcome)], sites(:first).drafts
    assert_equal [content_drafts(:cupcake_unfinished), content_drafts(:cupcake_welcome)], sites(:hostess).drafts
  end
  
  def test_liquid_keys
    assert_equal ['host', 'subtitle', 'title'], sites(:first).to_liquid.keys.sort
  end
end
