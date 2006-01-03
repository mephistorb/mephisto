require File.dirname(__FILE__) + '/../test_helper'

class TaggingTest < Test::Unit::TestCase
  fixtures :articles, :tags, :taggings

  def test_should_not_allow_duplicate_taggings
    assert_equal 1, articles(:another).taggings.length
    assert !articles(:another).taggings.build(:tag => tags(:home)).valid?
  end
end
