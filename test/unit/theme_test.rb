require File.dirname(__FILE__) + '/../test_helper'

context "Theme" do
  fixtures :sites

  def setup
    prepare_theme_fixtures
    @theme = sites(:first).theme
  end

  specify "should find preview" do
    assert @theme.preview.exist?
  end

  specify "should respond to to_param for routes" do
    assert_equal 'current', @theme.to_param
  end

  specify "should export files" do
    @theme.export 'foo', :to => THEME_ROOT
    
    THEME_FILES.each do |path|
      assert File.exists?(File.join(THEME_ROOT, 'foo', path)), "#{path} does not exist"
    end
  end

  specify "should export files as zip" do 
    @theme.export_as_zip 'foo', :to => THEME_ROOT
    
    assert File.exists?(File.join(THEME_ROOT, 'foo.zip'))
    
    Zip::ZipFile.open File.join(THEME_ROOT, 'foo.zip') do |zip|
      THEME_FILES.each do |path|
        assert zip.file.exists?(path), "#{path} does not exist"
      end
    end
  end

  specify "should import files" do
    dest = THEME_ROOT + 'site-1/other/hemingway'
    Theme.import THEME_ROOT + 'site-1/hemingway.zip', :to => dest
    assert dest.exist?
    THEME_FILES.each do |file|
      assert((dest + file).exist?, "#{file} does not exist")
    end
  end
  
  specify "should not import bad theme" do
    dest = THEME_ROOT + 'site-1/other/hemingway'
    assert_raise ThemeError do
      Theme.import THEME_ROOT + 'site-1/bad-hemingway.zip', :to => dest
    end
    assert !dest.exist?
  end
end
