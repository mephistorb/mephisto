require File.dirname(__FILE__) + '/../test_helper'

context "Template" do
  fixtures :sites

  def setup
    prepare_theme_fixtures
  end

  def test_should_count_correct_assets
    assert_equal 12, sites(:first).templates.size
    assert_equal 3,  sites(:hostess).templates.size
  end

  def test_should_carry_theme_reference
    assert_equal sites(:first).theme.path, sites(:first).templates.theme.path
  end

  def test_should_find_templates
    t = sites(:first).templates['archive']
    assert_equal (sites(:first).attachment_path + "templates/archive.liquid"), t
    assert t.file?
  end
  
  def test_should_not_find_find_missing_template
    t = sites(:hostess).templates['archive']
    assert_equal (sites(:hostess).attachment_path + "templates/archive.liquid"), t
    assert !t.file?
  end

  def test_should_find_preferred_template
    assert_template_name :single
    assert_template_name :section
    assert_template_name :archive
    assert_template_name :page
    assert_template_name :search
    assert_template_name :error
    assert_template_name :tag
  end

  def test_should_find_fallback_templates
    [:tag, :error, :search, :section].each { |t| sites(:first).templates[t].unlink }
    assert_template_name :archive, :section
    assert_template_name :archive, :search
    assert_template_name :archive, :tag
    
    sites(:first).templates[:page].unlink
    assert_template_name :single, :page

    sites(:first).templates[:archive].unlink
    sites(:first).templates[:single].unlink
    assert_template_name :index, :single
    assert_template_name :index, :section
    assert_template_name :index, :archive
    assert_template_name :index, :page
    assert_template_name :index, :search
    assert_template_name :index, :error
    assert_template_name :index, :tag
  end

  def test_should_find_preferred_with_custom_template
    assert_template_name :home, :section, :custom => 'home.liquid'
  end

  def test_should_find_custom
    assert_equal ['alt_layout.liquid', 'author.liquid', 'home.liquid'], sites(:first).templates.custom.sort
  end

  protected
    def assert_template_name(expected_template_name, template_type = nil, options = {})
      template_type ||= expected_template_name
      site = options[:site] || sites(:first)
      assert_equal(expected_template_name.nil? ? nil : site.templates[expected_template_name], site.templates.find_preferred(template_type, options[:custom]))
    end
end
