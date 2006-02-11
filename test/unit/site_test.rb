require File.dirname(__FILE__) + '/../test_helper'

class SiteTest < Test::Unit::TestCase
  fixtures :sites

  # Replace this with your real tests.
  def test_truth
    assert_kind_of Site, sites(:first)
  end
end
