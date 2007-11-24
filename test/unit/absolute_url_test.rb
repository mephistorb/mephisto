require File.dirname(__FILE__) + '/../test_helper'

# DEPRECATED, see spec/filters/absolute_url_spec.rb

context "Default Url" do
  include Mephisto::Liquid::UrlMethods
  
  specify "should have root absolute url" do
    assert_equal '/', absolute_url
  end
  
  specify "should join url pieces" do
    assert_equal '/foo', absolute_url(:foo)
    assert_equal '/foo/bar', absolute_url(:foo, :bar)
    assert_equal '/foo/bar/baz.html', absolute_url(:foo, :bar, 'baz.html')
  end
  
  specify "should join relative path" do
    assert_equal '/foo/bar/baz.html', absolute_url('foo/bar/baz.html')
  end
  
  specify "should join absolute path" do
    assert_equal '/foo/bar/baz.html', absolute_url('/foo/bar/baz.html')
  end
  
  specify "should join path ending with a slash" do
    assert_equal '/foo/bar/baz', absolute_url('foo/bar/baz/')
  end
end

context "Custom Relative Url" do
  include Mephisto::Liquid::UrlMethods
  attr_reader :relative_url_root
  
  def setup
    @relative_url_root = '/blog'
  end
  
  specify "should have root absolute url" do
    assert_equal '/blog/', absolute_url
  end
  
  specify "should join url pieces" do
    assert_equal '/blog/foo',              absolute_url(:foo)
    assert_equal '/blog/foo/bar',          absolute_url(:foo, :bar)
    assert_equal '/blog/foo/bar/baz.html', absolute_url(:foo, :bar, 'baz.html')
  end
  
  specify "should join relative path" do
    assert_equal '/blog/foo/bar/baz.html', absolute_url('foo/bar/baz.html')
  end
  
  specify "should join absolute path" do
    assert_equal '/foo/bar/baz.html', absolute_url('/foo/bar/baz.html')
  end
  
  specify "should join path ending with a slash" do
    assert_equal '/blog/foo/bar/baz', absolute_url('foo/bar/baz/')
  end
end