require File.dirname(__FILE__) + '/../test_helper'

class AssignedSectionTest < Test::Unit::TestCase
  fixtures :contents, :sections, :assigned_sections

  def test_should_not_allow_duplicate_assigned_sections
    assert_equal 1, contents(:another).assigned_sections.length
    assert !contents(:another).assigned_sections.build(:section => sections(:home)).valid?
  end

  def test_should_increment_articles_count_cache
    assert_difference sections(:home), :articles_count do
      AssignedSection.create! :article => contents(:site_map), :section => sections(:home)
      sections(:home).reload
    end
  end
  
  def test_should_decrement_articles_count_cache
    assert_difference sections(:home), :articles_count, -1 do
      assigned_sections(:welcome_home).destroy
      sections(:home).reload
    end
  end
end
