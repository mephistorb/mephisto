require File.dirname(__FILE__) + '/../test_helper'

class ThemeTest < Test::Unit::TestCase
  fixtures :sites

  def setup
    prepare_theme_fixtures
    @theme = sites(:first).theme
  end

  THEME_FILES = [
    'about.yml',
    'preview.png',
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

  def test_should_find_preview
    assert @theme.preview.exist?
  end

  def test_should_respond_to_to_param_for_routes
    assert_equal 'current', @theme.to_param
  end

  def test_should_export_files
    @theme.export 'foo', :to => THEME_ROOT
    
    THEME_FILES.each do |path|
      assert File.exists?(File.join(THEME_ROOT, 'foo', path)), "#{path} does not exist"
    end
  end

  def test_should_export_files_as_zip
    @theme.export_as_zip 'foo', :to => THEME_ROOT
    
    assert File.exists?(File.join(THEME_ROOT, 'foo.zip'))
    
    Zip::ZipFile.open File.join(THEME_ROOT, 'foo.zip') do |zip|
      THEME_FILES.each do |path|
        assert zip.file.exists?(path), "#{path} does not exist"
      end
    end
  end
end
