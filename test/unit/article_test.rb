require File.dirname(__FILE__) + '/../test_helper'

class ArticleTest < Test::Unit::TestCase
  fixtures :articles

  # Replace this with your real tests.
  def test_truth
    assert_kind_of Article, articles(:first)
  end
end
