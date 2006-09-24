require File.dirname(__FILE__) + '/../test_helper'

class ResourceTest < Test::Unit::TestCase
  fixtures :sites

  def setup
    prepare_theme_fixtures
  end

  def test_should_count_correct_assets
    assert_equal 3, sites(:first).resources.size
    assert_equal 0, sites(:hostess).resources.size
  end

  def test_should_carry_theme_reference
    assert_equal sites(:first).theme.path, sites(:first).resources.theme.path
  end

  def test_should_add_resource
    f = sites(:hostess).resources.write 'foo.css'
    assert_equal (sites(:hostess).attachment_path + 'stylesheets/foo.css'), f
    assert !f.file?
  end

  def test_should_add_and_create_resource
    f = sites(:hostess).resources.write 'foo.css', 'foo'
    assert_equal (sites(:hostess).attachment_path + 'stylesheets/foo.css'), f
    assert_equal 'foo', f.read
    assert f.file?
  end
end
