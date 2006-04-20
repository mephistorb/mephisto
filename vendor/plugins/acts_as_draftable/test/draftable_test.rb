require File.join(File.dirname(__FILE__), 'abstract_unit')

class DraftableTest < Test::Unit::TestCase
  fixtures :posts, :post_drafts
  set_fixture_class :post_drafts => Post::Draft

  def test_should_set_correct_defaults
    assert_equal 'Draft',       Post.draft_class_name
    assert_equal 'post_drafts', Post.draft_table_name
  end

  def test_should_retrieve_current_draft
    assert_equal post_drafts(:welcome), posts(:welcome).draft
    assert_equal posts(:welcome),       post_drafts(:welcome).post
  end

  def test_should_count_new_drafts
    assert_difference Post::Draft, :count_new do
      Post.new(:title => 'foo').save_draft
    end
  end

  def test_should_find_new_drafts
    assert_equal [post_drafts(:first), post_drafts(:cupcake_unfinished)], Post::Draft.find_new(:all)
    Post.new(:title => 'foo').save_draft
    assert_equal 3, Post::Draft.find_new(:all).length
  end

  def test_should_change_draft_to_unsaved_post
    post = Post::Draft.new(:title => 'foo').to_post
    assert post.new_record?
    assert_equal 'foo', post.title
  end

  def test_should_change_post_draft_to_post
    drafted_post = post_drafts(:welcome).to_post
    assert_equal posts(:welcome), drafted_post
    assert_equal 'Welcome to Mephisto',    posts(:welcome).title
    assert_equal 'Welcome to ArticleCast', post_drafts(:welcome).to_post.title
  end

  def test_should_load_post_from_draft
    assert_equal 'Welcome to Mephisto',    posts(:welcome).title
    posts(:welcome).load_from_draft
    assert_equal 'Welcome to ArticleCast', post_drafts(:welcome).to_post.title
  end

  def test_should_save_draft_of_new_post
    assert_no_difference Post, :count do
      assert_difference Post::Draft, :count do
        post = Post.new(:title => 'foo')
        post.save_draft
        assert_equal 'foo', post.draft.title
      end
    end
  end

  def test_should_remove_draft_when_creating_post
    assert_difference Post, :count do
      assert_difference Post::Draft, :count, -1 do
        post = post_drafts(:first).to_post
        assert post.save
      end
    end
  end

  def test_should_remove_draft_when_saving_post
    assert_difference Post::Draft, :count, -1 do
      assert posts(:welcome).save
    end
  end
end
