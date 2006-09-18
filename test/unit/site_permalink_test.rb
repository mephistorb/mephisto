require File.dirname(__FILE__) + '/../test_helper'
require 'site'

context "Site Permalink Validations" do
  fixtures :sites
  
  def setup
    @site = sites(:first)
  end
  
  specify "should strip ending and beginning slashes" do
    @site.permalink_style = '/:year/:month/:day/:permalink/'
    assert_valid @site
    assert_equal ':year/:month/:day/:permalink', @site.permalink_style
  end
  
  specify "should not allow empty paths" do
    @site.permalink_style = ':year//:month/:day/:permalink'
    assert !@site.valid?
    assert_match /blank/, @site.errors.on(:permalink_style)
  end
  
  specify "should require either permalink or id" do
    @site.permalink_style = ':year/:month/:day'
    assert !@site.valid?
    assert_equal "must contain either :permalink or :id", @site.errors.on(:permalink_style)
  end
  
  specify "should require at least year for any date based permalinks" do
    %w(month day).each do |var|
      @site.permalink_style = ":#{var}/:id"
      assert !@site.valid?
      assert_equal "must contain :year for any date-based permalinks", @site.errors.on(:permalink_style)
    end
  end
  
  specify "should require valid attributes" do
    @site.permalink_style = ':year/:month/:day/:permalink/:id'
    assert_valid @site

    @site.permalink_style = ':year/:foo/:month/:day/:permalink'
    assert !@site.valid?
    assert_equal "cannot contain 'foo' variable", @site.errors.on(:permalink_style)
  end
end

context "Site Permalink Regular Expression" do 
  fixtures :sites
  
  def setup
    @site = sites(:first)
  end

  specify "should create permalink regex" do
    assert_equal Regexp.new(%(^(\\d{4})\\/(\\d{1,2})\\/(\\d{1,2})\\/([a-z0-9-]+)(\/comments(\/(\\d+))?)?$)), @site.permalink_regex
    
    @site.permalink_style = "articles/:id/:permalink"
    assert_equal Regexp.new(%(^articles\\/(\\d+)\\/([a-z0-9-]+)(\/comments(\/(\\d+))?)?$)), @site.permalink_regex(true)
  end
end

context "Site Permalink Generation" do
  fixtures :sites, :contents
  
  def setup
    @site    = sites(:first)
    @article = contents(:welcome)
  end

  specify "should generate correct permalink format" do
    assert_equal "/#{@article.year}/#{@article.month}/#{@article.day}/#{@article.permalink}", @site.permalink_for(@article)
  end

  specify "should generate correct permalink format for draft" do
    @article.published_at = nil
    now = Time.now.utc
    assert_equal "/#{now.year}/#{now.month}/#{now.day}/#{@article.permalink}", @site.permalink_for(@article)
  end

  specify "should generate custom id permalink" do
    @site.permalink_style = 'posts/:year/:id'
    assert_valid @site
    assert_equal "/posts/#{@article.year}/#{@article.id}", @site.permalink_for(@article)
  end
end