require File.dirname(__FILE__) + '/../test_helper'

context "Basic Filters" do
  include Mephisto::Liquid::Filters

  def setup
    @context = {}
  end
  
  specify "should assign variable" do
    assert_nil @context['foo']
    assign_to 'blah', 'foo'
    assert_equal 'blah', @context['foo']
  end
end

context "Url Filters" do
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
  
  specify "should generate tag links" do
    assert_equal "<a href=\"/tags/foo\">foo</a>", link_to_tag('foo')
  end
  
  specify "should generate search urls" do
    assert_equal '/search?q=abc',        search_url('abc')
    assert_equal '/search?q=abc&page=2', search_url('abc', 2)
  end
end

context "Drop Filters" do
  fixtures :sites, :sections, :contents, :assigned_sections
  include Mephisto::Liquid::Filters

  def setup
    @context = {'site' => sites(:first).to_liquid, 'section' => sections(:about).to_liquid}
  end

  specify "should find section by path" do
    assert_equal sections(:home),  find_section('').source
    assert_equal sections(:about), find_section('about').source
  end
  
  specify "should find latest articles by section" do
    section = sections(:home).to_liquid
    assert_models_equal [contents(:welcome), contents(:another)], latest_articles(section).collect(&:source)
    assert_models_equal [contents(:welcome), contents(:another)], latest_articles(section, 2).collect(&:source)
    assert_equal contents(:welcome), latest_article(section).source
  end
end