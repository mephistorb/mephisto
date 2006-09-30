require File.dirname(__FILE__) + '/../test_helper'

context "Dispatcher" do
  fixtures :sites, :sections

  specify "should dispatch to home" do
    assert_dispatch :list, sections(:home), %w()
  end

  specify "should dispatch to home archives" do
    assert_dispatch :archives, sections(:home), %w(archives)
  end

  specify "should dispatch to home monthly archives" do
    assert_dispatch :archives, sections(:home), '2006', '9', %w(archives 2006 9)
  end

  specify "should error on invalid archive dispatch" do
    assert_dispatch :error, sections(:home), 'archives', 'foo', %w(archives foo)
    assert_dispatch :error, sections(:home), 'archives', '2006', 'foo', %w(archives 2006 foo)
    assert_dispatch :error, sections(:home), 'archives', '2006', '9', 'foo', %w(archives 2006 9 foo)
  end

  specify "should dispatch page sections" do
    assert_dispatch :page, sections(:about), %w(about)
    assert_dispatch :page, sections(:about), 'foo', %w(about foo)
  end

  specify "should not allow page name on blog sections" do 
    assert_dispatch :error, sections(:home), 'foo', %w(foo)
  end

  specify "should dispatch to tags" do
    assert_dispatch :tags, nil, %w(tags)
    assert_dispatch :tags, nil, 'a', %w(tags a)
    assert_dispatch :tags, nil, 'a', 'b', %w(tags a b)
  end

  specify "should dispatch to search" do
    assert_dispatch :search, nil, %w(search)
  end
  
  specify "should error on invalid search" do
    assert_dispatch :error, nil, %w(search foo)
  end

  specify "should dispatch to permalink" do
    options = {:year => '2006', :month => '9', :day => '1', :permalink => 'foo'}
    assert_dispatch :single, nil, options, %w(2006 9 1 foo)
  end

  specify "should dispatch to comments" do
    options = {:year => '2006', :month => '9', :day => '1', :permalink => 'foo'}
    assert_dispatch :comments, nil, options, %w(2006 9 1 foo comments)
  end

  specify "should dispatch to comments feed" do
    options = {:year => '2006', :month => '9', :day => '1', :permalink => 'foo'}
    assert_dispatch :comments_feed, nil, options, %w(2006 9 1 foo comments.xml)
  end

  specify "should dispatch to changes feed" do
    options = {:year => '2006', :month => '9', :day => '1', :permalink => 'foo'}
    assert_dispatch :changes_feed, nil, options, %w(2006 9 1 foo changes.xml)
  end

  specify "should dispatch to single comment" do
    options = {:year => '2006', :month => '9', :day => '1', :permalink => 'foo'}
    assert_dispatch :comment, nil, options, '5', %w(2006 9 1 foo comments 5)
  end

  specify "should not dispatch bad permalinks" do
    assert_dispatch :error, sections(:home), 'entries', '5', 'foo-bar-baz', %w(entries 5 foo-bar-baz)
    assert_dispatch :error, sections(:home), '200', '9', '1', 'foo', %w(200 9 1 foo)
    assert_dispatch :error, sections(:home), '2006', '239', '1', 'foo', %w(2006 239 1 foo)
    assert_dispatch :error, sections(:home), '2006', '9', '123', 'foo', %w(2006 9 123 foo)
    assert_dispatch :error, sections(:home), '2006', '9', '1', 'foo', 'boo', %w(2006 9 1 foo boo)
    assert_dispatch :error, sections(:home), '2006', '9', '1', 'foo', 'comment', %w(2006 9 1 foo comment)
    assert_dispatch :error, nil, '', 'foo', ['', 'foo']
  end

  specify "should handle denied requests" do
    %w(deny/foo/bar deny/foo/bar/baz limited_deny deny/bar/baz/blah).each { |path| assert_denied path }
  end

  specify "should redirect without variable matches" do
    assert_redirected_to '/to/here', 'redirect/from/here'
    assert_redirected_to '/bar',     'sanitize/path'
  end
  
  specify "should redirect with unused variable matches" do
    assert_redirected_to 'http://external', 'redirect/external'
  end
  
  specify "should redirect with wildcard match" do
    assert_redirected_to '/this/foo',     'redirect/match/wildcard/foo'
    assert_redirected_to '/this/foo/bar', 'redirect/match/wildcard/foo/bar'
  end

  specify "should redirect and match multiple vars" do
    assert_redirected_to '/this/bar/foo',     'redirect/match/vars/foo/bar'
    assert_redirected_to '/this/bar/baz/foo', 'redirect/match/vars/foo/bar/baz'
  end

  protected
    def assert_dispatch(dispatch_type, section, *args)
      path   = args.pop
      result = Mephisto::Dispatcher.run sites(:first), path
      assert_equal [dispatch_type, section, *args], result
    end

    def assert_denied(path)
      result = Mephisto::Dispatcher.run sites(:first), path.split('/')
      assert_equal :redirect,  result.first
      assert_equal :not_found, result.last
    end

    def assert_redirected_to(expected, path)
      result = Mephisto::Dispatcher.run sites(:first), path.split('/')
      assert_equal :redirect, result.shift
      assert_equal :moved_permanently, result.first
      assert_equal expected, result.last[:location]
    end
end

context "Dispatcher Permalink Regular Expression" do 
  fixtures :sites
  
  def setup
    @site = sites(:first)
  end

  specify "should create permalink regex with default permalink style" do
    assert_equal Regexp.new(%(^(\\d{4})\\/(\\d{1,2})\\/(\\d{1,2})\\/([\\w\\-]+)(\/(comments(\/(\\d+))?|comments\.xml|changes\.xml))?$)), 
      Mephisto::Dispatcher.build_permalink_regex_with(@site.permalink_style).first
  end

  specify "should create permalink regex with custom style" do
    @site.permalink_style = "articles/:id/:permalink"
    assert_equal Regexp.new(%(^articles\\/(\\d+)\\/([\\w\\-]+)(\/(comments(\/(\\d+))?|comments\.xml|changes\.xml))?$)), 
      Mephisto::Dispatcher.build_permalink_regex_with(@site.permalink_style).first
  end

  specify "should pull out permalink variables from default permalink style" do
    assert_equal [:year, :month, :day, :permalink],
      Mephisto::Dispatcher.build_permalink_regex_with(@site.permalink_style).last
  end

  specify "should pull out permalink variables from custom style" do
    @site.permalink_style = "articles/:id/:permalink"
    assert_equal [:id, :permalink], 
      Mephisto::Dispatcher.build_permalink_regex_with(@site.permalink_style).last
  end
end

context "Dispatcher Permalink Recognition" do
  fixtures :sites

  def setup
    @site = sites(:first)
  end

  specify "should recognize permalinks with default permalink style" do
    options = {:year => '2006', :month => '9', :day => '1', :permalink => 'foo-bar_baz'}
    assert_equal [options, nil, nil], Mephisto::Dispatcher.recognize_permalink(@site, %w(2006 9 1 foo-bar_baz))
  end
  
  specify "should recognize permalinks with custom style" do
    @site.permalink_style = 'entries/:id/:permalink'
    options = {:id => '5', :permalink => 'foo-bar_baz'}
    assert_equal [options, nil, nil], Mephisto::Dispatcher.recognize_permalink(@site, %w(entries 5 foo-bar_baz))
  end

  specify "should recognize permalinks with comment and default permalink style" do
    options = {:year => '2006', :month => '9', :day => '1', :permalink => 'foo'}
    assert_equal [options, 'comments',     nil], Mephisto::Dispatcher.recognize_permalink(@site, %w(2006 9 1 foo comments))
    assert_equal [options, 'comments',     '5'], Mephisto::Dispatcher.recognize_permalink(@site, %w(2006 9 1 foo comments 5))
    assert_equal [options, 'comments.xml', nil], Mephisto::Dispatcher.recognize_permalink(@site, %w(2006 9 1 foo comments.xml))
    assert_equal [options, 'changes.xml',  nil], Mephisto::Dispatcher.recognize_permalink(@site, %w(2006 9 1 foo changes.xml))
  end
  
  specify "should recognize permalinks with comment and custom style" do
    @site.permalink_style = 'entries/:id/:permalink'
    options = {:id => '5', :permalink => 'foo-bar-baz'}
    assert_equal [options, 'comments',     nil], Mephisto::Dispatcher.recognize_permalink(@site, %w(entries 5 foo-bar-baz comments))
    assert_equal [options, 'comments',     '5'], Mephisto::Dispatcher.recognize_permalink(@site, %w(entries 5 foo-bar-baz comments 5))
    assert_equal [options, 'comments.xml', nil], Mephisto::Dispatcher.recognize_permalink(@site, %w(entries 5 foo-bar-baz comments.xml))
    assert_equal [options, 'changes.xml',  nil], Mephisto::Dispatcher.recognize_permalink(@site, %w(entries 5 foo-bar-baz changes.xml))
  end

  specify "should ignore unrecognized permalinks" do
    assert_nil Mephisto::Dispatcher.recognize_permalink(sites(:first), %w(entries 5 foo-bar-baz))
    assert_nil Mephisto::Dispatcher.recognize_permalink(sites(:first), %w(200 9 1 foo))
    assert_nil Mephisto::Dispatcher.recognize_permalink(sites(:first), %w(2006 239 1 foo))
    assert_nil Mephisto::Dispatcher.recognize_permalink(sites(:first), %w(2006 9 123 foo))
    assert_nil Mephisto::Dispatcher.recognize_permalink(sites(:first), %w(2006 9 1 foo boo))
    assert_nil Mephisto::Dispatcher.recognize_permalink(sites(:first), %w(2006 9 1 foo comment))
    assert_nil Mephisto::Dispatcher.recognize_permalink(sites(:first), %w(2006 9 1 foo comments.xml 5))
    assert_nil Mephisto::Dispatcher.recognize_permalink(sites(:first), %w(2006 9 1 foo changes.xml 5))
  end
end