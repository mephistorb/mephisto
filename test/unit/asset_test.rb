require File.dirname(__FILE__) + '/../test_helper'

class AssetTest < Test::Unit::TestCase
  fixtures :assets, :db_files

  def test_should_require_path
    a = Asset.create :content_type => 'text/plain', :filename => 'foo.txt', :data => 'foobar'
    assert a.new_record?
    assert a.errors.on(:path)
  end

  def test_should_sanitize_path
    a = Asset.create :content_type => 'text/plain', :filename => 'foo.txt', :data => 'foobar', :path => '//foo/bar/baz////'
    assert a.id
    assert_equal 'foo/bar/baz', a.path
  end
end
