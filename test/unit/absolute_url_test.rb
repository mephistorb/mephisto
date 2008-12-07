require File.dirname(__FILE__) + '/../test_helper'

# DEPRECATED, see spec/filters/absolute_url_spec.rb

class DefaultUrlTest < ActiveSupport::TestCase
  include Mephisto::Liquid::UrlMethods
  
  test "should have root absolute url" do
    assert_equal '/', absolute_url
  end
  
  test "should join url pieces" do
    assert_equal '/foo', absolute_url(:foo)
    assert_equal '/foo/bar', absolute_url(:foo, :bar)
    assert_equal '/foo/bar/baz.html', absolute_url(:foo, :bar, 'baz.html')
  end
  
  test "should join relative path" do
    assert_equal '/foo/bar/baz.html', absolute_url('foo/bar/baz.html')
  end
  
  test "should join absolute path" do
    assert_equal '/foo/bar/baz.html', absolute_url('/foo/bar/baz.html')
  end
  
  test "should join path ending with a slash" do
    assert_equal '/foo/bar/baz', absolute_url('foo/bar/baz/')
  end
end

class CustomRelativeUrlTest < ActiveSupport::TestCase
  include Mephisto::Liquid::UrlMethods
  attr_reader :relative_url_root
  
  def setup
    @relative_url_root = '/blog'
  end
  
  test "should have root absolute url" do
    assert_equal '/blog/', absolute_url
  end
  
  test "should join url pieces" do
    assert_equal '/blog/foo',              absolute_url(:foo)
    assert_equal '/blog/foo/bar',          absolute_url(:foo, :bar)
    assert_equal '/blog/foo/bar/baz.html', absolute_url(:foo, :bar, 'baz.html')
  end
  
  test "should join relative path" do
    assert_equal '/blog/foo/bar/baz.html', absolute_url('foo/bar/baz.html')
  end
  
  test "should join absolute path" do
    assert_equal '/foo/bar/baz.html', absolute_url('/foo/bar/baz.html')
  end
  
  test "should join path ending with a slash" do
    assert_equal '/blog/foo/bar/baz', absolute_url('foo/bar/baz/')
  end
end