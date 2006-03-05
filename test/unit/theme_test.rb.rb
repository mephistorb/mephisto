require File.dirname(__FILE__) + '/../test_helper'

class ThemeTest < Test::Unit::TestCase
  fixtures :attachments, :db_files
  THEME_ROOT = File.join(RAILS_ROOT, 'tmp/themes')

  def setup
    FileUtils.rm_rf THEME_ROOT
  end

  def test_should_select_theme_files
    files = Theme.find_current
    assert_equal 12, files.length
    assert files.include?(attachments(:layout))
  end

  def test_should_export_files
    Theme.export 'foo', :to => THEME_ROOT
    
    [
      'images',
      'javascripts/behavior.js',
      'layouts/layout.liquid',
      'stylesheets/style.css',
      'templates/archive.liquid',
      'templates/author.liquid',
      'templates/error.liquid',
      'templates/home.liquid',
      'templates/index.liquid',
      'templates/page.liquid',
      'templates/search.liquid',
      'templates/section.liquid',
      'templates/single.liquid'
    ].each do |path|
      assert File.exists?(File.join(THEME_ROOT, 'foo', path)), "#{path} does not exist"
    end
  end
end
