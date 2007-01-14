require File.dirname(__FILE__) + '/../test_helper'
context "Url Filters" do
  fixtures :sites, :sections, :contents
  include CoreFilters, UrlFilters

  def setup
    @context = mock_context 'site' => sites(:first).to_liquid, 'section' => sections(:about).to_liquid
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

  specify "should generate paged url when site has paged home section" do
    @context = mock_context 'site' => sites(:hostess).to_liquid, 'section' => sections(:cupcake_home).to_liquid
    assert_equal "/", page_url(contents(:cupcake_welcome).to_liquid(:page => true))
    assert_equal "/welcome-to-cupcake", page_url(contents(:cupcake_welcome).to_liquid)
  end

  specify "should generate paged url for home section" do
    assert_equal "/",                    page_url(contents(:welcome).to_liquid(:page => true), sections(:home).to_liquid)
    assert_equal "/welcome-to-mephisto", page_url(contents(:welcome).to_liquid, sections(:home).to_liquid)
  end
  
  specify "should generate section links" do
    other_section = link_to_section(sections(:home).to_liquid)
    home_section  = link_to_section(sections(:about).to_liquid)
    
    assert_match    %r(href="/"),         other_section
    assert_match    %r(href="/about"),    home_section
    assert_match    %r(class="selected"), home_section
    assert_no_match %r(class="selected"), other_section
  end

  specify "should generate paged url for home section" do
    assert_equal "/",                    page_url(contents(:welcome).to_liquid(:page => true), sections(:home).to_liquid)
    assert_equal "/welcome-to-mephisto", page_url(contents(:welcome).to_liquid, sections(:home).to_liquid)
  end

  specify "should generate asset urls" do
    assert_equal "/javascripts/foo.js",  javascript_url('foo.js')
    assert_equal "/stylesheets/foo.css", stylesheet_url('foo.css')
    assert_equal "/images/foo.gif",      asset_url('foo.gif')
  end
  
  specify "should include javascript tag" do
    script = javascript('foo')
    assert_match /^<script/, script
    assert_match %r(src="/javascripts/foo.js"), script
  end

  specify "should link stylesheet tag" do
    css = stylesheet('foo')
    assert_match /^<link/, css
    assert_match %r(href="/stylesheets/foo.css"), css
  end

  specify "should create image tag" do
    img = img_tag('foo.gif')
    assert_match /^<img/, img
    assert_match %r(src="/images/foo.gif"), img
    assert_match %r(alt="foo"), img
  end

  specify "should generate tag urls" do
    assert_equal "/tags",         tag_url
    assert_equal "/tags/foo",     tag_url('foo')
    assert_equal "/tags/foo/bar", tag_url('foo', 'bar')
  end
  
  specify "should generate tag links" do
    assert_equal "<a href=\"/tags/foo\" rel=\"tag\">foo</a>", link_to_tag('foo')
  end
  
  specify "should generate search urls" do
    assert_equal '/search?q=abc',        search_url('abc')
    assert_equal '/search?q=abc&page=2', search_url('abc', 2)
  end
  
  specify "should generate atom auto discovery tag" do
    content = atom_feed('/feed/foo')
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
  
  specify "should show section comments feed" do
    content = comments_feed(sections(:home).to_liquid)
    assert_match /href="\/feed\/comments.xml"/, content
    assert_match /title="Comments for Home"/, content
  end
  
  specify "should show section comments feed with custom title" do
    content = comments_feed(sections(:about).to_liquid, "About Comments")
    assert_match /href="\/feed\/about\/comments.xml"/, content
    assert_match /title="About Comments"/, content
  end
  
  specify "should show section articles feed" do
    content = articles_feed(sections(:home).to_liquid)
    assert_match /href="\/feed\/atom.xml"/, content
    assert_match /title="Articles for Home"/, content
  end
  
  specify "should show section articles feed with custom title" do
    content = articles_feed(sections(:about).to_liquid, "About Articles")
    assert_match /href="\/feed\/about\/atom.xml"/, content
    assert_match /title="About Articles"/, content
  end
  
  specify "should html encoding of anchor text" do
    unencoded = 'Tom & Jerry'
    contents(:welcome).title = unencoded
    @article = contents(:welcome).to_liquid
    @article.context = @context
    @context['section'].instance_variable_get(:@liquid)['name'] = unencoded
    assert_match %r{>Tom &amp; Jerry<\/a>}, link_to_article(@article)
    assert_match %r{>Tom &amp; Jerry<\/a>}, link_to_page(@article)
    assert_match %r{>Tom &amp; Jerry<\/a>}, link_to_section(@context['section'])
    assert_match %r{>Tom &amp; Jerry<\/a>}, link_to_tag(unencoded)
  end
end

context "Article Url Filters" do
  fixtures :sites, :sections, :contents
  include CoreFilters, UrlFilters

  def setup
    @context   = mock_context 'site' => sites(:first).to_liquid
    @article   = contents(:welcome).to_liquid
    @article.context = @context
    @permalink = @article.url
  end

  specify "should show article comments feed" do
    content = comments_feed(@article)
    assert_match /href="#{@permalink}\/comments\.xml"/, content
    assert_match /title="Comments for Welcome to Mephisto"/, content
  end
  
  specify "should show article comments feed with custom title" do
    content = comments_feed(@article, "Welcome Comments")
    assert_match /title="Welcome Comments"/, content
  end
  
  specify "should show article changes feed" do
    content = changes_feed(@article)
    assert_match /href="#{@permalink}\/changes\.xml"/, content
    assert_match /title="Changes for Welcome to Mephisto"/, content
  end
  
  specify "should show article changes feed with custom title" do
    content = changes_feed(@article, "Welcome Changes")
    assert_match /title="Welcome Changes"/, content
  end
end