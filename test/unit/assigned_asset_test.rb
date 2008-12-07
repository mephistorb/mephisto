require File.dirname(__FILE__) + '/../test_helper'

class AssignedAssetTest < ActiveSupport::TestCase
  fixtures :assigned_assets, :contents, :assets

  test "should find article assets" do
    assert_equal 3, contents(:welcome).assigned_assets.count
    assert_models_equal [assets(:gif), assets(:mp3)], contents(:welcome).assets
  end
  
  test "should add asset to article" do
    assert_difference AssignedAsset, :count do
      contents(:welcome).assets.add assets(:mov), 'avatar'
    end
    assert_models_equal [assets(:gif), assets(:mp3), assets(:mov)], contents(:welcome).assets(true)
    assert_equal 'avatar', contents(:welcome).assets[2].label
  end
  
  test "should add inactive asset to article" do
    assert_no_difference AssignedAsset, :count do
      contents(:welcome).assets.add assets(:png), 'avatar'
    end
    assert_models_equal [assets(:gif), assets(:mp3), assets(:png)], contents(:welcome).assets(true)
    assert_equal 'avatar', contents(:welcome).assets[2].label
  end

  test "should find deactivate article assets" do
    assert_no_difference AssignedAsset, :count do
      contents(:welcome).assets.remove assets(:mp3)
    end
    assert_models_equal [assets(:gif)], contents(:welcome).assets
  end
end
