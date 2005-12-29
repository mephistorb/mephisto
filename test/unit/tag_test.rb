require File.dirname(__FILE__) + '/../test_helper'

class TagTest < Test::Unit::TestCase
  fixtures :tags

  # Replace this with your real tests.
  def test_truth
    assert_kind_of Tag, tags(:first)
  end
end
