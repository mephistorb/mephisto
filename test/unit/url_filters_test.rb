require File.dirname(__FILE__) + '/../test_helper'
context "Url Filters" do
  fixtures :sites, :sections, :contents
  include CoreFilters, UrlFilters

  def setup
    @context = mock_context 'site' => sites(:first).to_liquid, 'section' => sections(:about).to_liquid
  end
  
  it "should generate archive url" do
    assert_equal "/archives", archive_url(sections(:home).to_liquid)
    assert_equal "/archives/foo/bar", archive_url(sections(:home).to_liquid, 'foo', 'bar')
  end
  
  it "should generate monthly url from date" do
    assert_equal "/archives/2006/1",       monthly_url(sections(:home).to_liquid, Date.new(2006, 1))
    assert_equal "/about/archives/2006/1", monthly_url(sections(:about).to_liquid, Date.new(2006, 1))
  end

  it "should generate monthly url from time" do
    assert_equal "/archives/2006/1",       monthly_url(sections(:home).to_liquid, Time.utc(2006, 1))
    assert_equal "/about/archives/2006/1", monthly_url(sections(:about).to_liquid, Time.utc(2006, 1))
  end

  it "should generate monthly url from string" do
    assert_equal "/archives/2006/1",       monthly_url(sections(:home).to_liquid, '2006-1')
    assert_equal "/about/archives/2006/1", monthly_url(sections(:about).to_liquid, '2006-1-4')
  end

  it "should generate monthly link" do
    assert_equal "<a href=\"/archives/2006/1\" title=\"January 2006\">January 2006</a>", link_to_month(sections(:home).to_liquid, '2006-1')
  end

  it "should generate paged url" do
    assert_equal "/about",                     page_url(contents(:welcome).to_liquid(:page => true))
    assert_equal "/about/welcome-to-mephisto", page_url(contents(:welcome).to_liquid)
    assert_equal "/about/about-this-page",     page_url(contents(:about).to_liquid)
  end

  it "should generate paged url when site has paged home section" do
    @context = mock_context 'site' => sites(:hostess).to_liquid, 'section' => sections(:cupcake_home).to_liquid
    assert_equal "/", page_url(contents(:cupcake_welcome).to_liquid(:page => true))
    assert_equal "/welcome-to-cupcake", page_url(contents(:cupcake_welcome).to_liquid)
  end

  it "should generate paged url for home section" do
    assert_equal "/",                    page_url(contents(:welcome).to_liquid(:page => true), sections(:home).to_liquid)
    assert_equal "/welcome-to-mephisto", page_url(contents(:welcome).to_liquid, sections(:home).to_liquid)
  end
  
  it "should generate section links" do
    other_section = link_to_section(sections(:home).to_liquid)
    home_section  = link_to_section(sections(:about).to_liquid)
    
    assert_match    %r(href="/"),                         other_section
    assert_match    %r(href="/about"),                    home_section
    assert_match    %r(class="selected"),                 home_section
    assert_no_match %r(class="selected"),                 other_section
    assert_match    %r(title="#{sections(:home).name}"),  other_section
    assert_match    %r(title="#{sections(:about).name}"), home_section
  end

  it "should generate paged url for home section" do
    assert_equal "/",                    page_url(contents(:welcome).to_liquid(:page => true), sections(:home).to_liquid)
    assert_equal "/welcome-to-mephisto", page_url(contents(:welcome).to_liquid, sections(:home).to_liquid)
  end

  it "should generate asset urls" do
    assert_equal "/javascripts/foo.js",  javascript_url('foo.js')
    assert_equal "/stylesheets/foo.css", stylesheet_url('foo.css')
    assert_equal "/images/foo.gif",      asset_url('foo.gif')
  end
  
  it "should include javascript tag" do
    script = javascript('foo')
    assert_match /^<script/, script
    assert_match %r(src="/javascripts/foo.js"), script
  end

  it "should link stylesheet tag" do
    css = stylesheet('foo')
    assert_match /^<link/, css
    assert_match %r(href="/stylesheets/foo.css"), css
  end

  it "should create image tag" do
    img = img_tag('foo.gif')
    assert_match /^<img/, img
    assert_match %r(src="/images/foo.gif"), img
    assert_match %r(alt="foo"), img
  end

  it "should generate tag urls" do
    assert_equal "/tags",           tag_url
    assert_equal "/tags/foo",       tag_url('foo')
    assert_equal "/tags/foo/bar",   tag_url('foo', 'bar')
    assert_equal '/tags/foo%20bar', tag_url('foo bar')
  end
  
  it "should generate tag links" do
    assert_equal "<a href=\"/tags/foo\" rel=\"tag\" title=\"foo\">foo</a>", link_to_tag('foo')
  end
  
  it "should generate search urls" do
    assert_equal '/search?q=abc',            search_url('abc')
    assert_equal '/search?q=abc&amp;page=2', search_url('abc', 2)
  end
  
  it "should generate atom auto discovery tag" do
    content = atom_feed('/feed/foo')
    assert_match /^<link /, content
    assert_match /rel="alternate"/, content
    assert_match /type="application\/atom\+xml"/, content
    assert_match /href="\/feed\/foo"/, content
    assert_no_match /title/, content
  end
  
  it "should generate atom auto discovery tag with title" do
    content = atom_feed('foo', 'bar')
    assert_match /title="bar"/, content
  end
  
  it "should show all comments feed" do
    content = all_comments_feed
    assert_match /href="\/feed\/all_comments.xml"/, content
    assert_match /title="All Comments"/, content
  end
  
  it "should show all comments feed with custom title" do
    content = all_comments_feed "All Lame Comments"
    assert_match /title="All Lame Comments"/, content
  end
  
  it "should show section comments feed" do
    content = comments_feed(sections(:home).to_liquid)
    assert_match /href="\/feed\/comments.xml"/, content
    assert_match /title="Comments for Home"/, content
  end
  
  it "should show section comments feed with custom title" do
    content = comments_feed(sections(:about).to_liquid, "About Comments")
    assert_match /href="\/feed\/about\/comments.xml"/, content
    assert_match /title="About Comments"/, content
  end
  
  it "should show section articles feed" do
    content = articles_feed(sections(:home).to_liquid)
    assert_match /href="\/feed\/atom.xml"/, content
    assert_match /title="Articles for Home"/, content
  end
  
  it "should show section articles feed with custom title" do
    content = articles_feed(sections(:about).to_liquid, "About Articles")
    assert_match /href="\/feed\/about\/atom.xml"/, content
    assert_match /title="About Articles"/, content
  end
	  
  it "should html encode anchor text" do
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
  
  it "should link to search result with article link" do
    @article = contents(:welcome).to_liquid
    @article.context = @context
    @context['section'] = nil
    assert_match /href="\/\d{4}\/\d+\/\d+\/welcome-to-mephisto"/, link_to_search_result(@article)
  end
  
  it "should link to search result with page link" do
    @article = contents(:welcome).to_liquid(:page => true)
    @article.context = @context
    @article2 = contents(:another).to_liquid
    @article2.context = @context
    assert_match /href="\/about"/, link_to_search_result(@article)
    assert_match /href="\/about\/another-welcome-to-mephisto"/, link_to_search_result(@article2)
  end
end

context "Link_to Url Filters" do
  fixtures :sites, :sections, :contents
  include CoreFilters, UrlFilters

  def setup
    @context = mock_context 'site' => sites(:first).to_liquid
    @section = sections(:about).to_liquid
    @article = contents(:welcome).to_liquid
    @paged_article = contents(:about).to_liquid
    @article.context = @paged_article.context = @context
  end

  it "should generate links with custom text" do
    pattern = %r(^<a href="[^"]+" (?:rel="tag" )?title="Custom text">Custom text</a>$)
    args = 'Custom text'
    assert_match pattern, link_to_article(@article, args)
    assert_match pattern, link_to_page(@article, @section, args)
    assert_match pattern, link_to_section(@section, args)
    assert_match pattern, link_to_comments(@article, args)
    assert_match pattern, link_to_tag('foo', args)
    assert_match pattern, link_to_month(@section, '2006-1', 'my', args)
    assert_match pattern, link_to_search_result(@article, args)
    @context['section'] = @section
    assert_match pattern, link_to_search_result(@paged_article, args)
  end

  it "should generate links with custom title attribute" do
    pattern = %r(^<a href="[^"]+" (?:rel="tag" )?title="Custom title">)
    args = [nil, 'Custom title']
    assert_match pattern, link_to_article(@article, *args)
    assert_match pattern, link_to_page(@article, @section, *args)
    assert_match pattern, link_to_section(@section, *args)
    assert_match pattern, link_to_comments(@article, *args)
    assert_match pattern, link_to_tag('foo', *args)
    assert_match pattern, link_to_month(@section, '2006-1', 'my', *args)
    assert_match pattern, link_to_search_result(@article, *args)
    @context['section'] = @section
    assert_match pattern, link_to_search_result(@paged_article, *args)
  end

  it "should generate links with custom id attribute" do
    pattern = %r(^<a href="[^"]+" id="custom-id" (?:rel="tag" )?title="[^"]+">)
    args = [nil, nil, 'custom-id']
    assert_match pattern, link_to_article(@article, *args)
    assert_match pattern, link_to_page(@article, @section, *args)
    assert_match pattern, link_to_section(@section, *args)
    assert_match pattern, link_to_comments(@article, *args)
    assert_match pattern, link_to_tag('foo', *args)
    assert_match pattern, link_to_month(@section, '2006-1', 'my', *args)
    assert_match pattern, link_to_search_result(@article, *args)
    @context['section'] = @section
    assert_match pattern, link_to_search_result(@paged_article, *args)
  end

  it "should generate links with custom class attribute" do
    pattern = %r(^<a class="custom-class" href="[^"]+" (?:rel="tag" )?title="[^"]+">)
    args = [nil, nil, nil, 'custom-class']
    assert_match pattern, link_to_article(@article, *args)
    assert_match pattern, link_to_page(@article, @section, *args)
    assert_match pattern, link_to_section(@section, *args)
    assert_match pattern, link_to_comments(@article, *args)
    assert_match pattern, link_to_tag('foo', *args)
    assert_match pattern, link_to_month(@section, '2006-1', 'my', *args)
    assert_match pattern, link_to_search_result(@article, *args)
    @context['section'] = @section
    assert_match pattern, link_to_search_result(@paged_article, *args)
  end

  it "should generate links with custom rel attribute" do
    pattern = %r(^<a href="[^"]+" rel="custom-rel" title="[^"]+">)
    args = [nil, nil, nil, nil, 'custom-rel']
    assert_match pattern, link_to_article(@article, *args)
    assert_match pattern, link_to_page(@article, @section, *args)
    assert_match pattern, link_to_section(@section, *args)
    assert_match pattern, link_to_comments(@article, *args)
    assert_match pattern, link_to_tag('foo', *args)
    assert_match pattern, link_to_month(@section, '2006-1', 'my', *args)
    assert_match pattern, link_to_search_result(@article, *args)
    @context['section'] = @section
    assert_match pattern, link_to_search_result(@paged_article, *args)
  end
  
  it "should html encode custom attributes" do
    pattern = %r(^<a class="custom&amp;class" href="[^"]+" id="custom&amp;id" rel="custom&amp;rel" title="Custom &amp; title">Custom &amp; text</a>$)
    args = ['Custom & text', 'Custom & title', 'custom&id', 'custom&class', 'custom&rel']
    assert_match pattern, link_to_article(@article, *args)
    assert_match pattern, link_to_page(@article, @section, *args)
    assert_match pattern, link_to_section(@section, *args)
    assert_match pattern, link_to_comments(@article, *args)
    assert_match pattern, link_to_tag('foo', *args)
    assert_match pattern, link_to_month(@section, '2006-1', 'my', *args)
    assert_match pattern, link_to_search_result(@article, *args)
    @context['section'] = @section
    assert_match pattern, link_to_search_result(@paged_article, *args)
  end

  it "should generate page links with selected class appended to custom class attribute" do
    pattern = %r(class="custom-class selected")
    args    = [nil, nil, nil, 'custom-class']

    @context['section'] = @section
    @context['article'] = @paged_article

    assert_match    pattern, link_to_page(@paged_article, @section, *args)
    assert_no_match pattern, link_to_page(@article, @section, *args)
   end

  it "should generate section links with selected class appended to custom class attribute" do
    pattern = %r(class="custom-class selected")
    args    = [nil, nil, nil, 'custom-class']

    @context['section'] = @section

    assert_match    pattern, link_to_section(@section, *args)
    assert_no_match pattern, link_to_section(sections(:home).to_liquid, *args)
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

  it "should show article comments feed" do
    content = comments_feed(@article)
    assert_match /href="#{@permalink}\/comments\.xml"/, content
    assert_match /title="Comments for Welcome to Mephisto"/, content
  end
  
  it "should show article comments feed with custom title" do
    content = comments_feed(@article, "Welcome Comments")
    assert_match /title="Welcome Comments"/, content
  end
  
  it "should show article changes feed" do
    content = changes_feed(@article)
    assert_match /href="#{@permalink}\/changes\.xml"/, content
    assert_match /title="Changes for Welcome to Mephisto"/, content
  end
  
  it "should show article changes feed with custom title" do
    content = changes_feed(@article, "Welcome Changes")
    assert_match /title="Welcome Changes"/, content
  end
end
