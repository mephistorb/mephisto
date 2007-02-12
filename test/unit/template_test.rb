require File.dirname(__FILE__) + '/../test_helper'

context "Template" do
  fixtures :sites

  def setup
    prepare_theme_fixtures
  end

  def test_should_count_correct_assets
    assert_equal 12, sites(:first).templates.size
    assert_equal 5,  sites(:hostess).templates.size
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

  def test_should_find_preferred_with_custom_template
    assert_equal(sites(:first).templates[:home], sites(:first).templates.find_preferred(:section, 'home.liquid'))
  end

  def test_should_find_custom
    assert_equal ['alt_layout.liquid', 'author.liquid', 'home.liquid', 'index.liquid', 'page.liquid'], sites(:first).templates.custom.sort
    assert_equal ['alt_layout.liquid', 'author.liquid', 'home.liquid', 'index.liquid', 'page.liquid'], sites(:first).templates.custom(".liquid").sort
  end

  def test_template_types_should_use_extension
    assert_equal ["archive.liquid", "error.liquid", "layout.liquid", "search.liquid", "section.liquid", "single.liquid", "tag.liquid"], sites(:first).templates.template_types
    assert_equal ["archive.test", "error.test", "layout.test", "search.test", "section.test", "single.test", "tag.test"], sites(:first).templates.template_types(".test")
  end
  
  def test_collect_templates_find_correct_template
    assert sites(:first).templates.collect_templates(:section, nil).include?(sites(:first).theme.path+"templates/section.liquid") 
    assert sites(:first).templates.collect_templates(:section, "home.liquid").include?(sites(:first).theme.path+"templates/home.liquid") 
  end

end
