require File.dirname(__FILE__) + '/../test_helper'

class SiteTest < Test::Unit::TestCase
  fixtures :sites, :contents, :attachments, :db_files
  
  def test_should_validate_host
    assert_valid sites(:first)
    assert_equal true, Site.create(:host => sites(:first).host, :title => 'Copy').new_record?
  end  

  def test_should_set_default_comment_behavior
    site = Site.new :host => 'foo'
    assert site.valid?, site.errors.full_messages.to_sentence
    assert  site.accept_comments?
    assert !site.approve_comments?
  end

  def test_should_create_section_without_accepting_comments
    site = Site.new :host => 'foo', :accept_comments => false
    assert site.valid?, site.errors.full_messages.to_sentence
    assert !site.accept_comments?
    assert !site.approve_comments?
  end

  def test_should_create_section_with_approving_comments
    site = Site.new :host => 'foo', :approve_comments => true
    assert site.valid?, site.errors.full_messages.to_sentence
    assert site.accept_comments?
    assert site.approve_comments?
  end

  def test_should_find_valid_articles
    assert_equal contents(:welcome), sites(:first).articles.find(:first, :order => 'contents.id')
    assert_equal contents(:cupcake_welcome), sites(:hostess).articles.find(:first, :order => 'contents.id')
  end
  
  def test_should_find_host
    assert_equal sites(:first), Site.find_by_host('test.host')
    assert_equal sites(:hostess), Site.find_by_host('cupcake.host')
  end

  def test_should_allow_empty_filter
    sites(:first).update_attribute :filters, ['']
    assert_equal [], sites(:first).reload.filters
  end

  def test_liquid_keys
    assert_equal ['host', 'subtitle', 'title'], sites(:first).to_liquid.keys.sort
  end
end
