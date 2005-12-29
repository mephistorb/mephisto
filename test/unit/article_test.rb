require File.dirname(__FILE__) + '/../test_helper'

class ArticleTest < Test::Unit::TestCase
  fixtures :articles

  def test_should_create_permalink
    a = Article.create :title => 'This IS a Tripped out title!!!1  (well not really)'
    assert_equal 'this_is_a_tripped_out_title_1_well_not_really', a.permalink
  end
end
