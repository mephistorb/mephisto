require File.dirname(__FILE__) + '/../test_helper'

class DispatcherTest < Test::Unit::TestCase
  fixtures :sites, :sections
  # ['']
  # ['about']
  
  def test_should_dispatch_to_home
    assert_dispatch :list, sections(:home), %w()
  end

  def test_should_dispatch_to_home_archives
    assert_dispatch :archives, sections(:home), 'archives', %w(archives)
  end

  def test_should_dispatch_to_home_monthly_archives
    assert_dispatch :archives, sections(:home), 'archives', '2006', '9', %w(archives 2006 9)
  end

  def test_should_error_on_invalid_archive_dispatch
    assert_dispatch :error, sections(:home), 'archives', 'foo', %w(archives foo)
    assert_dispatch :error, sections(:home), 'archives', '2006', 'foo', %w(archives 2006 foo)
    assert_dispatch :error, sections(:home), 'archives', '2006', '9', 'foo', %w(archives 2006 9 foo)
  end

  def test_should_dispatch_page_sections
    assert_dispatch :page, sections(:about), %w(about)
    assert_dispatch :page, sections(:about), 'foo', %w(about foo)
  end

  def test_should_not_allow_page_name_on_blog_sections
    assert_dispatch :error, sections(:home), 'foo', %w(foo)
  end

  def test_should_dispatch_to_tags
    assert_dispatch :tags, nil, %w(tags)
    assert_dispatch :tags, nil, 'a', %w(tags a)
    assert_dispatch :tags, nil, 'a', 'b', %w(tags a b)
  end

  protected
    def assert_dispatch(dispatch_type, section, *args)
      path   = args.pop
      result = Mephisto::Dispatcher.run sites(:first), path
      assert_equal [dispatch_type, section, *args], result
    end
end