require File.dirname(__FILE__) + '/../test_helper'
require 'site'

context "Site Permalink Validations" do
  fixtures :sites
  
  def setup
    @site = sites(:first)
  end
  
  specify "should strip ending and beginning slashes" do
    @site.permalink_slug = '/:year/:month/:day/:permalink/'
    assert_valid @site
    assert_equal ':year/:month/:day/:permalink', @site.permalink_slug
  end
  
  specify "should not allow empty paths" do
    @site.permalink_slug = ':year//:month/:day/:permalink'
    assert !@site.valid?
    assert_match /blank/, @site.errors.on(:permalink_slug)
  end
  
  specify "should require valid attributes" do
    @site.permalink_slug = ':year/:month/:day/:permalink/:id'
    assert_valid @site

    @site.permalink_slug = ':year/:foo/:month/:day/:permalink'
    assert !@site.valid?
    assert_equal "cannot contain 'foo' variable", @site.errors.on(:permalink_slug)
  end
end

context "Site Permalink Regular Expression" do 
  fixtures :sites
  
  def setup
    @site = sites(:first)
  end

  specify "should create permalink regex" do
    assert_equal Regexp.new(%(^(\\d{4})\\/(\\d{1,2})\\/(\\d{1,2})\\/([a-z0-9-]+)$)), @site.permalink_regex
    
    @site.permalink_slug = "articles/:id/:permalink"
    assert_equal Regexp.new(%(^articles\\/(\\d+)\\/([a-z0-9-]+)$)), @site.permalink_regex(true)
  end
end