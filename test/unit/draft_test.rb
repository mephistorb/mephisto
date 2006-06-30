require File.dirname(__FILE__) + '/../test_helper'

class DraftTest < Test::Unit::TestCase
  fixtures :contents, :users, :content_drafts, :sites
  set_fixture_class :content_drafts => Article::Draft

  def test_should_set_correct_defaults
    assert_equal 'Draft',          Article.draft_class_name
    assert_equal 'content_drafts', Article.draft_table_name
  end

  def test_should_retrieve_current_draft
    assert_equal content_drafts(:welcome), contents(:welcome).draft
    assert_equal contents(:welcome),       content_drafts(:welcome).article
  end

  def test_should_count_new_drafts
    assert_difference Article::Draft, :count_new do
      Article.new(:title => 'foo', :site_id => 1).save_draft
    end
  end

  def test_should_find_new_drafts
    assert_equal [content_drafts(:first), content_drafts(:cupcake_unfinished)], Article::Draft.find_new(:all, :order => 'id')
    assert_equal [content_drafts(:first)], sites(:first).drafts.find_new(:all)
    assert_equal [content_drafts(:cupcake_unfinished)], sites(:hostess).drafts.find_new(:all)
    
    assert_difference Article::Draft, :count_new, 2 do
      assert_difference sites(:first).drafts, :count_new, 2 do
        Article.new(:title => 'foo', :site_id => 1).save_draft
        sites(:first).articles.create(:title => 'bar', :site_id => 1).save_draft
      end
    end
  end

  def test_should_change_draft_to_unsaved_article
    article = Article::Draft.new(:title => 'foo').to_article
    assert article.new_record?
    assert_equal 'foo', article.title
  end

  def test_should_change_article_draft_to_article
    draft_article = content_drafts(:welcome).to_article
    assert_equal contents(:welcome), draft_article
    assert_equal 'Welcome to Mephisto',    contents(:welcome).title
    assert_equal 'Welcome to ArticleCast', content_drafts(:welcome).to_article.title
  end

  def test_should_load_article_from_draft
    assert_equal 'Welcome to Mephisto',    contents(:welcome).title
    contents(:welcome).load_from_draft
    assert_equal 'Welcome to ArticleCast', content_drafts(:welcome).to_article.title
  end

  def test_should_save_draft_of_new_article
    assert_no_difference Article, :count do
      assert_difference Article::Draft, :count do
        article = Article.new(:title => 'foo', :site_id => 1)
        article.save_draft
        assert_equal 'foo', article.draft.title
        assert_equal 1, article.draft.site_id
      end
    end
  end

  def test_should_remove_draft_when_creating_article
    assert_difference Article, :count do
      assert_difference Article::Draft, :count, -1 do
        article = content_drafts(:first).to_article
        article.attributes = { :user => users(:quentin) }
        assert article.save
      end
    end
  end

  def test_should_remove_draft_when_saving_article
    assert_difference Article::Draft, :count, -1 do
      assert contents(:welcome).save
    end
  end
end
