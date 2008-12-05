require File.dirname(__FILE__) + '/../spec_helper'

describe Mephisto::Liquid::UrlMethods, "#absolute_url" do
  include Mephisto::Liquid::UrlMethods

  it "has root absolute url" do
    absolute_url.should == '/'
  end
  
  it "joins url pieces" do
    absolute_url(:foo).should                   == '/foo'
    absolute_url(:foo, :bar).should             == '/foo/bar'
    absolute_url(:foo, :bar, 'baz.html').should == '/foo/bar/baz.html' 
  end
  
  it "joins relative path" do
    absolute_url('foo/bar/baz.html').should == '/foo/bar/baz.html'
  end
  
  it "joins absolute path" do
    absolute_url('/foo/bar/baz.html').should == '/foo/bar/baz.html'
  end
  
  it "joins path ending with a slash" do
    absolute_url('foo/bar/baz/').should == '/foo/bar/baz'
  end
end

describe Mephisto::Liquid::UrlMethods, "#absolute_url (with custom url root)" do
  include Mephisto::Liquid::UrlMethods

  class << self
    attr_accessor :relative_url_root
  end
  
  before do
    stub!(:relative_url_root).and_return("/blog")
  end

  it "has root absolute url" do
    absolute_url.should == '/blog/'
  end
  
  it "joins url pieces" do
    absolute_url(:foo).should                   == '/blog/foo'
    absolute_url(:foo, :bar).should             == '/blog/foo/bar'
    absolute_url(:foo, :bar, 'baz.html').should == '/blog/foo/bar/baz.html' 
  end
  
  it "joins relative path" do
    absolute_url('foo/bar/baz.html').should == '/blog/foo/bar/baz.html'
  end
  
  it "joins absolute path" do
    absolute_url('/foo/bar/baz.html').should == '/foo/bar/baz.html'
  end
  
  it "joins path ending with a slash" do
    absolute_url('foo/bar/baz/').should == '/blog/foo/bar/baz'
  end
end
