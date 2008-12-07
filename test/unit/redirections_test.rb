require File.dirname(__FILE__) + '/../test_helper'

class RedirectionsTest < ActiveSupport::TestCase
  delegate :redirections,       :to => Mephisto::Routing
  delegate :handle_redirection, :to => Mephisto::Routing

  test "should sanitize path" do
    assert_not_nil redirections[/^sanitize\/path$/], redirections.inspect
  end
  
  test "should sanitize destination" do
    assert_equal '/bar', redirections[/^sanitize\/path$/]
    assert_equal 'http://external/$1/$2', redirections[/^redirect\/external$/]
  end
  
  test "should convert path to regex" do
    assert_not_nil redirections[/^deny\/foo\/(.*)$/]
    assert_not_nil redirections[/^redirect\/from\/(.*)$/]
    assert_not_nil redirections[/^redirect\/match\/wildcard\/(.*)$/]
  end
  
  test "should convert last question to asterisk" do
    assert_not_nil redirections[/^redirect\/match\/vars\/([^\/]+)\/(.*)$/]
    assert_not_nil redirections[/^deny\/bar\/([^\/]+)\/(.*)$/]
  end
  
  test "should handle denied redirections" do
    %w(deny/foo/bar deny/foo/bar/baz limited_deny deny/bar/baz/blah).each do |url|
      assert_equal [:not_found], handle_redirection(url)
    end
  end
  
  test "should not handle mismatched patterns" do
    %w(deny/bar/baz limited_deny/foo).each do |url|
      assert_nil handle_redirection(url)
    end
  end
  
  test "should redirect without variable matches" do
    assert_redirected_to '/to/here', 'redirect/from/here'
    assert_redirected_to '/bar',     'sanitize/path'
  end
  
  test "should redirect with unused variable matches" do
    assert_redirected_to 'http://external', 'redirect/external'
  end
  
  test "should redirect with wildcard match" do
    assert_redirected_to '/this/foo',     'redirect/match/wildcard/foo'
    assert_redirected_to '/this/foo/bar', 'redirect/match/wildcard/foo/bar'
  end

  test "should redirect and match multiple vars" do
    assert_redirected_to '/this/bar/foo',     'redirect/match/vars/foo/bar'
    assert_redirected_to '/this/bar/baz/foo', 'redirect/match/vars/foo/bar/baz'
  end

  protected
    def assert_redirected_to(expected, path)
      args = handle_redirection(path)
      assert_equal :moved_permanently, args.first
      assert_equal expected, args.last[:location]
    end
end