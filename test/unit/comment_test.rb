require File.dirname(__FILE__) + '/../test_helper'

class CommentTest < Test::Unit::TestCase
  fixtures :articles

  def test_sti_associations
    assert_equal articles(:welcome), articles(:welcome_comment).article
    assert_equal [articles(:welcome_comment)], articles(:welcome).comments
  end
end
