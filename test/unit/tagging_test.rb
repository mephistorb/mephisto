require File.dirname(__FILE__) + '/../test_helper'

class TaggingTest < Test::Unit::TestCase
  fixtures :taggings

  # Replace this with your real tests.
  def test_truth
    assert_kind_of Tagging, taggings(:welcome_home)
  end
end
