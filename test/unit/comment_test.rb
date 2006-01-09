require File.dirname(__FILE__) + '/../test_helper'

class CommentTest < Test::Unit::TestCase
  fixtures :articles

  def test_sti_associations
    assert_equal articles(:welcome), articles(:welcome_comment).article
    assert_equal [articles(:welcome_comment)], articles(:welcome).comments
  end

  def test_add_comment
    assert_difference Comment, :count do
      assert_difference articles(:welcome), :comments_count do
        articles(:welcome).comments.create :description => 'test comment', :author => 'bob', :author_ip => '127.0.0.1'
        articles(:welcome).reload
      end
    end
  end

  def test_add_comment
    c = articles(:welcome).comments.create :description => '*test* comment', :author => 'bob', :author_ip => '127.0.0.1'
    assert_equal "<p><strong>test</strong> comment</p>", c.description_html
  end

  def test_should_return_correct_author_link
    assert_equal 'rico',                            articles(:welcome_comment).author_link
    articles(:welcome_comment).author_url = 'abc'
    assert_equal %Q{<a href="http://abc">rico</a>}, articles(:welcome_comment).author_link
    articles(:welcome_comment).author_url = 'https://abc'
    assert_equal %Q{<a href="https://abc">rico</a>}, articles(:welcome_comment).author_link
  end
end
