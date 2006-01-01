require File.dirname(__FILE__) + '/../test_helper'

class TemplateTest < Test::Unit::TestCase
  fixtures :templates

  # Replace this with your real tests.
  def test_preferred_template_hierarchy_sanity
    assert_template_type :home,   :main
    assert_template_type :single, :single
    assert_template_type :tag,    :tag
    #assert_template_type :page,   :page
    #assert_template_type :author, :author
    assert_template_type :search, :search
    #assert_template_type :error,  :error
  end

  def test_fallback_templates
    [:home, :single, :tag, :page, :author, :search, :error].each { |n| templates(n).destroy }
    assert_template_type :index,   :main
    assert_template_type :index,   :single
    assert_template_type :archive, :tag
    #assert_template_type :index,   :page
    #assert_template_type :archive, :author
    assert_template_type :index,   :search
    #assert_template_type :index,   :error

    templates(:archive).destroy
    assert_template_type :index, :tag
    #assert_template_type :index, :author
  end

  protected
  def assert_template_type(expected_template_name, template_type)
    assert_equal(templates(expected_template_name).data, Template.find_preferred(template_type))
  end
end
