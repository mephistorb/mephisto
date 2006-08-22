require File.dirname(__FILE__) + '/../test_helper'

class ThemeTest < Test::Unit::TestCase
  fixtures :sites

  def setup
    FileUtils.rm_rf THEME_ROOT
    FileUtils.mkdir_p THEME_ROOT
    prepare_theme_fixtures
  end

  THEME_ROOT = File.join(RAILS_ROOT, 'tmp/themes')
  THEME_FILES = [
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
  ]

  def test_should_export_files
    sites(:first).attachments.export 'foo', :to => THEME_ROOT
    
    THEME_FILES.each do |path|
      assert File.exists?(File.join(THEME_ROOT, 'foo', path)), "#{path} does not exist"
    end
  end

  def test_should_export_files_as_zip
    sites(:first).attachments.export_as_zip 'foo', :to => THEME_ROOT
    
    assert File.exists?(File.join(THEME_ROOT, 'foo.zip'))
    
    Zip::ZipFile.open File.join(THEME_ROOT, 'foo.zip') do |zip|
      THEME_FILES.each do |path|
        assert zip.file.exists?(path), "#{path} does not exist"
      end
    end
  end
end
