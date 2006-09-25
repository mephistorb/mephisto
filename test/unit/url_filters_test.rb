require File.dirname(__FILE__) + '/../test_helper'
context "Url Filters" do
  fixtures :sites, :sections, :contents
  include CoreFilters, UrlFilters

  def setup
    @context = {'site' => sites(:first).to_liquid, 'section' => sections(:about).to_liquid}
  end
  
  specify "should generate archive url" do
    assert_equal "/archives", archive_url(sections(:home).to_liquid)
    assert_equal "/archives/foo/bar", archive_url(sections(:home).to_liquid, 'foo', 'bar')
  end
  
  specify "should generate monthly url from date" do
    assert_equal "/archives/2006/1",       monthly_url(sections(:home).to_liquid, Date.new(2006, 1))
    assert_equal "/about/archives/2006/1", monthly_url(sections(:about).to_liquid, Date.new(2006, 1))
  end

  specify "should generate monthly url from time" do
    assert_equal "/archives/2006/1",       monthly_url(sections(:home).to_liquid, Time.utc(2006, 1))
    assert_equal "/about/archives/2006/1", monthly_url(sections(:about).to_liquid, Time.utc(2006, 1))
  end

  specify "should generate monthly url from string" do
    assert_equal "/archives/2006/1",       monthly_url(sections(:home).to_liquid, '2006-1')
    assert_equal "/about/archives/2006/1", monthly_url(sections(:about).to_liquid, '2006-1-4')
  end

  specify "should generate monthly link" do
    assert_equal "<a href=\"/archives/2006/1\">January 2006</a>", link_to_month(sections(:home).to_liquid, '2006-1')
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
  
  specify "should generate tag links" do
    assert_equal "<a href=\"/tags/foo\">foo</a>", link_to_tag('foo')
  end
  
  specify "should generate search urls" do
    assert_equal '/search?q=abc',        search_url('abc')
    assert_equal '/search?q=abc&page=2', search_url('abc', 2)
  end
  
  specify "should generate atom auto discovery tag" do
    content = atom_feed('foo')
    assert_match /^<link /, content
    assert_match /rel="alternate"/, content
    assert_match /type="application\/atom\+xml"/, content
    assert_match /href="\/feed\/foo"/, content
    assert_no_match /title/, content
  end
  
  specify "should generate atom auto discovery tag with title" do
    content = atom_feed('foo', 'bar')
    assert_match /title="bar"/, content
  end
  
  specify "should show all comments feed" do
    content = all_comments_feed
    assert_match /href="\/feed\/all_comments.xml"/, content
    assert_match /title="All Comments"/, content
  end
  
  specify "should show all comments feed with custom title" do
    content = all_comments_feed "All Lame Comments"
    assert_match /title="All Lame Comments"/, content
  end
end