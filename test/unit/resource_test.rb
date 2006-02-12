require File.dirname(__FILE__) + '/../test_helper'

class ResourceTest < Test::Unit::TestCase
  fixtures :assets, :db_files

  def test_should_ignore_templates_and_other_assets
    assert_equal 2, Resource.count
  end

  def test_should_add_extension_if_necessary
    assert_equal 'foo.txt.css', Resource.create(:content_type => 'text/css',        :filename => 'foo.txt', :data => 'foobar').filename
    assert_equal 'foo.txt.js',  Resource.create(:content_type => 'text/javascript', :filename => 'foo.txt', :data => 'foobar').filename
    assert_equal 'foo.css',     Resource.create(:content_type => 'text/css',        :filename => 'foo.css', :data => 'foobar').filename
    assert_equal 'foo.js',      Resource.create(:content_type => 'text/javascript', :filename => 'foo.js',  :data => 'foobar').filename
  end

  def test_should_skip_extension_for_images
    assert_equal 'foo.txt', Resource.create(:content_type => 'image/png', :filename => 'foo.txt', :data => 'foobar').filename
    assert_equal 'foo.jpg', Resource.create(:content_type => 'image/png', :filename => 'foo.jpg', :data => 'foobar').filename
  end
end
