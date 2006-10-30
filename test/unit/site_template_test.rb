require File.dirname(__FILE__) + '/../test_helper'
context "Site Template" do
  fixtures :sites, :sections

  def setup
    prepare_theme_fixtures
  end

  specify "should set site theme path" do
    assert_equal Site.theme_path + 'site-1', sites(:first).theme_path
  end
  
  specify "should set attachment base path" do
    assert_equal Site.theme_path + 'site-1' + 'current', sites(:first).theme.path
  end

  specify "should set current theme" do
    assert_kind_of Theme, sites(:first).theme
    assert_equal Site.theme_path + 'site-1' + 'current', sites(:first).theme.path
  end

  specify "should find themes" do
    assert_equal %w(current empty encytemedia), sites(:first).themes.collect(&:name)
  end
  
  specify "should find current theme" do
    theme = sites(:first).themes[:current]
    assert theme.current?
    assert sites(:first).theme.current?
    assert_equal theme, sites(:first).theme
  end

  specify "should not barf on nil attributes for theme" do
    [:summary, :author, :version, :homepage].each { |attr_name| assert_nil sites(:first).themes[:empty].send(attr_name) }
  end

  specify "should default to name on empty title" do 
    assert_equal 'empty', sites(:first).themes[:empty].title
  end

  specify "should change theme" do
    theme = sites(:first).change_theme_to :encytemedia
    assert theme.current?
    assert theme.path.exist?, "#{theme.path.to_s} does not exist"
    assert_equal 'encytemedia', sites(:first).reload.current_theme_path
    assert_equal 'encytemedia', theme.name
    assert_equal 'Encytemedia', theme.title
  end

  specify "should import theme" do
    sites(:first).import_theme sites(:first).theme_path + 'hemingway.zip', 'hemingway'
    assert_equal %w(current empty encytemedia hemingway), sites(:first).themes.collect(&:name)
    THEME_FILES.each do |path|
      assert File.exists?(File.join(THEME_ROOT, 'site-1/other/hemingway', path)), "'site-1/other/hemingway/#{path}' does not exist"
    end
  end

  specify "should import theme named current" do
    sites(:first).import_theme sites(:first).theme_path + 'hemingway.zip', 'current'
    assert_equal %w(current current_2 empty encytemedia), sites(:first).themes.collect(&:name)
    THEME_FILES.each do |path|
      assert File.exists?(File.join(THEME_ROOT, 'site-1/other/current_2', path)), "'site-1/other/current_2/#{path}' does not exist"
    end

    sites(:first).import_theme sites(:first).theme_path + 'hemingway.zip', 'current'
    assert_equal %w(current current_2 current_3 empty encytemedia), sites(:first).themes.collect(&:name)
  end

  specify "should find themes and ignore duplicates" do
    sites(:first).change_theme_to :encytemedia
    assert_equal %w(current empty), sites(:first).themes.collect(&:name)
  end

  specify "should read yml attributes for theme" do
    theme = sites(:first).themes[:encytemedia]
    assert_equal 'Encytemedia',                  theme.title
    assert_equal 'Justin Palmer',                theme.author
    assert_equal 0.5,                            theme.version
    assert_equal 'http://encytemedia.com/blog/', theme.homepage
    assert_equal 'cool stuff',                   theme.summary
  end

  specify "should raise error on missing template" do
    sites(:first).templates[:archive].unlink
    sites(:first).templates[:index].unlink
    assert_raise MissingTemplateError do
      sites(:first).send(:set_content_template, sites(:first).sections.home, :archive)
    end
  end

  specify "should find preferred for site" do
    assert_site_template_name :home, :section
  end

  specify "should find fallback for site with preferred template" do
    FileUtils.rm File.join(THEME_ROOT, 'site-1', 'current', 'templates', 'home.liquid')
    assert_site_template_name :section, :section
  end

  specify "should find preferred for site layout" do
    FileUtils.cp File.join(THEME_ROOT, 'site-1', 'current', 'layouts', 'layout.liquid'), File.join(THEME_ROOT, 'site-1', 'current', 'layouts', 'custom_layout.liquid')
    sites(:first).sections.home.update_attribute :layout, 'custom_layout'
    assert_site_layout_name :custom_layout, :layout
  end

  specify "should find fallback for site with preferred layout" do
    sites(:first).sections.home.update_attribute :layout, 'custom_layout'
    assert_site_layout_name :layout
  end

  protected
    def assert_site_template_name(expected_template_name, template_type = nil, options = {})
      template_type ||= expected_template_name
      site            = options[:site] || sites(:first)
      section         = options[:section] || site.sections.home
      assert_equal(expected_template_name.nil? ? nil : site.templates[expected_template_name], site.send(:set_content_template, section, template_type))
    end

    def assert_site_layout_name(expected_template_name, template_type = nil, options = {})
      template_type ||= expected_template_name
      site            = options[:site] || sites(:first)
      section         = options[:section] || site.sections.home
      assert_equal(expected_template_name.nil? ? nil : site.templates[expected_template_name], site.send(:set_layout_template, section, template_type))
    end
end