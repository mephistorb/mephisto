require File.dirname(__FILE__) + '/../test_helper'

class SiteTest < Test::Unit::TestCase
  fixtures :sites, :contents, :attachments
  
  def test_should_validate_host
    assert_valid sites(:first)
    assert_no_difference Site, :count do
      assert_equal true, Site.create(:host => sites(:first).host.upcase, :title => 'Copy').new_record?
    end
  end

  def test_should_require_valid_host_name
    s = Site.new
    ['foo', '-34.com', 'A!'].each do |host|
      s.host = host
      s.valid?
      assert s.errors.on(:host), "host valid with #{host}"
    end
  end

  def test_should_set_default_comment_behavior
    site = Site.new :host => 'foo.com'
    assert_valid site
    assert  site.accept_comments?
    assert !site.approve_comments?
  end

  def test_should_create_section_without_accepting_comments
    site = Site.new :host => 'foo.com', :comment_age => -1
    assert_valid site
    assert !site.accept_comments?
    assert !site.approve_comments?
  end

  def test_should_create_section_with_approving_comments
    site = Site.new :host => 'foo.com', :approve_comments => true
    assert_valid site
    assert site.accept_comments?
    assert site.approve_comments?
  end

  def test_should_find_valid_articles
    assert_equal contents(:welcome), sites(:first).articles.find(:first, :order => 'contents.id')
    assert_equal contents(:cupcake_welcome), sites(:hostess).articles.find(:first, :order => 'contents.id')
  end
  
  def test_should_find_host
    assert_equal sites(:first), Site.find_by_host('test.com')
    assert_equal sites(:hostess), Site.find_by_host('cupcake.com')
  end

  def test_should_allow_empty_filter
    sites(:first).update_attribute :filters, ['']
    assert_equal [], sites(:first).reload.filters
  end
end
