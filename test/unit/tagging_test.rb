require File.dirname(__FILE__) + '/../test_helper'

class AssetTaggingTest < ActiveSupport::TestCase
  fixtures :taggings, :tags, :assets

  test "should show taggable tags" do
    assert_models_equal [tags(:ruby)], assets(:gif).tags
  end

  test "should add tags" do
    assert_difference Tagging, :count do
      assert_no_difference Tag, :count do
        Tagging.add_to assets(:gif), [tags(:rails)]
      end
    end
    assert_models_equal [tags(:rails), tags(:ruby)], assets(:gif).reload.tags
  end

  test "should delete tags" do
    assert_difference Tagging, :count, -1 do
      assert_no_difference Tag, :count do
        Tagging.delete_from assets(:gif), [tags(:ruby)]
      end
    end
    assert_equal [], assets(:gif).reload.tags
  end

  test "should change tags" do
    assert_difference Tagging, :count, 2 do
      assert_difference Tag, :count do
        Tagging.set_on assets(:gif), 'rails, mongrel, foo'
      end
    end
    assert_models_equal [Tag[:foo], tags(:mongrel), tags(:rails)], assets(:gif).reload.tags
  end

  test "should find by tags" do
    assert_models_equal [assets(:gif)], Asset.find_tagged_with('ruby, rails')
  end
end

class ArticleTaggingTest < ActiveSupport::TestCase
  fixtures :taggings, :tags, :contents, :sites

  test "should show taggable tags" do
    assert_models_equal [tags(:rails)], contents(:another).tags
  end

  test "should add tags" do
    assert_difference Tagging, :count do
      assert_no_difference Tag, :count do
        Tagging.add_to contents(:another), [tags(:ruby)]
      end
    end
    assert_models_equal [tags(:rails), tags(:ruby)], contents(:another).reload.tags
  end

  test "should delete tags" do
    assert_difference Tagging, :count, -1 do
      assert_no_difference Tag, :count do
        Tagging.delete_from contents(:another), [tags(:rails)]
      end
    end
    assert_equal [], contents(:another).reload.tags
  end

  test "should change tags" do
    assert_difference Tagging, :count, 2 do
      assert_difference Tag, :count do
        Tagging.set_on contents(:another), 'ruby, mongrel, foo'
      end
    end
    assert_models_equal [Tag[:foo], tags(:mongrel), tags(:ruby)], contents(:another).reload.tags
  end

  test "should find by tags in site" do
    assert_models_equal [tags(:mongrel), tags(:rails), tags(:ruby)], sites(:first).tags
  end
end
