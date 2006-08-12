require File.dirname(__FILE__) + '/../test_helper'

class SectionDropTest < Test::Unit::TestCase
  fixtures :sites, :sections

  def test_should_convert_section_to_drop
    assert_kind_of Liquid::Drop, sections(:home).to_liquid
  end
  
  def test_should_show_current_status
    assert  sections(:home).to_liquid(true).current
    assert !sections(:home).to_liquid.current
  end

  def test_should_expose_section_fields
    [:id, :name, :path, :articles_count].each do |attr|
      assert_equal sections(:home).send(attr), Mephisto::Liquid::SectionDrop.new(sections(:home)).before_method(attr)
    end
  end
  
  def test_should_report_section_types
    assert Mephisto::Liquid::SectionDrop.new(sections(:home)).is_blog
    [:about, :cupcake_home, :cupcake_about].each { |s| assert Mephisto::Liquid::SectionDrop.new(sections(s)).is_paged }
  end
end
