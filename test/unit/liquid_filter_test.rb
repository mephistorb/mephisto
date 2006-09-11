require File.dirname(__FILE__) + '/../test_helper'

context "Url Filter" do
  fixtures :sites, :sections, :contents
  include Mephisto::Liquid::Filters

  def setup
    @context = {'site' => sites(:first).to_liquid, 'section' => sections(:about).to_liquid}
  end

  specify "should generate tag url" do
    assert_equal "/tags/foo",     tag_url('foo')
    assert_equal "/tags/foo/bar", tag_url(%w(foo bar))
  end
  
  specify "should generate monthly url" do
    assert_equal "/archives/2006/1",       monthly_url(sections(:home).to_liquid, Date.new(2006, 1))
    assert_equal "/about/archives/2006/1", monthly_url(sections(:about).to_liquid, Date.new(2006, 1))
  end
  
  specify "should generate paged url" do
    assert_equal "/about",                     page_url(contents(:welcome).to_liquid(:page => true))
    assert_equal "/about/welcome-to-mephisto", page_url(contents(:welcome).to_liquid)
    assert_equal "/about/about-this-page",     page_url(contents(:about).to_liquid)
  end
  
  specify "should generate asset urls" do
    assert_equal "/javascripts/foo.js",  javascript_url('foo.js')
    assert_equal "/stylesheets/foo.css", stylesheet_url('foo.css')
    assert_equal "/images/foo.gif",      asset_url('foo.gif')
  end
  
  specify "should generate tag urls" do
    assert_equal "/tags",         tag_url
    assert_equal "/tags/foo",     tag_url('foo')
    assert_equal "/tags/foo/bar", tag_url('foo', 'bar')
  end
  
  specify "should generate search urls" do
    assert_equal '/search?q=abc',        search_url('abc')
    assert_equal '/search?q=abc&page=2', search_url('abc', 2)
  end
end