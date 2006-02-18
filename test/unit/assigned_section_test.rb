require File.dirname(__FILE__) + '/../test_helper'

class CategorizationTest < Test::Unit::TestCase
  fixtures :contents, :categories, :categorizations

  def test_should_not_allow_duplicate_categorizations
    assert_equal 1, contents(:another).categorizations.length
    assert !contents(:another).categorizations.build(:category => categories(:home)).valid?
  end
end
