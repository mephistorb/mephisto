require File.dirname(__FILE__) + '/../test_helper'

class CategorizationTest < Test::Unit::TestCase
  fixtures :articles, :categories, :categorizations

  def test_should_not_allow_duplicate_categorizations
    assert_equal 1, articles(:another).categorizations.length
    assert !articles(:another).categorizations.build(:category => categories(:home)).valid?
  end
end
