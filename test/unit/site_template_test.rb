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
    assert_equal Site.theme_path + 'site-1' + 'current', sites(:first).attachment_base_path
  end
  
  specify "should set other themes path" do
    assert_equal Site.theme_path + 'site-1' + 'other', sites(:first).other_themes_path
  end

  specify "should set current theme" do
    assert_kind_of Theme, sites(:first).theme
    assert_equal Site.theme_path + 'site-1' + 'current', sites(:first).theme.path
  end

  specify "should find other themes" do
    assert_equal %w(empty encytemedia), sites(:first).themes.collect(&:name)
  end

  specify "should not barf on nil attributes for theme" do
    [:title, :author, :version, :homepage].each { |attr_name| assert_nil sites(:first).themes.first.send(attr_name) }
  end

  specify "should read yml attributes for theme" do
    theme = sites(:first).themes[:encytemedia]
    assert_equal 'Encytemedia',                  theme.title
    assert_equal 'Justin Palmer',                theme.author
    assert_equal 0.5,                            theme.version
    assert_equal 'http://encytemedia.com/blog/', theme.homepage
  end

  specify "should raise error on missing template" do
    sites(:first).templates[:archive].unlink
    assert_raise Mephisto::MissingTemplateError do
      sites(:first).send(:parse_template, sites(:first).templates[:archive], {}, {})
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
      assert_equal(expected_template_name.nil? ? nil : site.templates[expected_template_name], site.send(:set_preferred_template, section, template_type))
    end
    def assert_site_layout_name(expected_template_name, template_type = nil, options = {})
      template_type ||= expected_template_name
      site            = options[:site] || sites(:first)
      section         = options[:section] || site.sections.home
      assert_equal(expected_template_name.nil? ? nil : site.templates[expected_template_name], site.send(:set_layout_template, section, template_type))
    end
end