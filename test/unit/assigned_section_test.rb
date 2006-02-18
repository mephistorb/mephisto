require File.dirname(__FILE__) + '/../test_helper'

class AssignedSectionTest < Test::Unit::TestCase
  fixtures :contents, :sections, :assigned_sections

  def test_should_not_allow_duplicate_assigned_sections
    assert_equal 1, contents(:another).assigned_sections.length
    assert !contents(:another).assigned_sections.build(:section => sections(:home)).valid?
  end
end
