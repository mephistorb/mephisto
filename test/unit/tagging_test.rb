require File.dirname(__FILE__) + '/../test_helper'

class TaggingTest < Test::Unit::TestCase
  fixtures :taggings, :tags, :assets

  def test_should_show_taggable_tags
    assert_models_equal [tags(:ruby)], assets(:gif).tags
  end

  def test_should_add_tags
    assert_difference Tagging, :count do
      assert_no_difference Tag, :count do
        Tagging.add_to assets(:gif), [tags(:rails)]
      end
    end
    assert_models_equal [tags(:rails), tags(:ruby)], assets(:gif).reload.tags
  end

  def test_should_delete_tags
    assert_difference Tagging, :count, -1 do
      assert_no_difference Tag, :count do
        Tagging.delete_from assets(:gif), [tags(:ruby)]
      end
    end
    assert_equal [], assets(:gif).reload.tags
  end
  
  def test_should_change_tags
    assert_difference Tagging, :count, 2 do
      assert_difference Tag, :count do
        Tagging.set_on assets(:gif), 'rails, mongrel, foo'
      end
    end
    assert_models_equal [Tag[:foo], tags(:mongrel), tags(:rails)], assets(:gif).reload.tags
  end
  
  def test_should_find_by_tags
    assert_models_equal [assets(:gif)], Asset.find_tagged_with('ruby, rails')
  end
end
