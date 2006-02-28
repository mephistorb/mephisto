require File.dirname(__FILE__) + '/../test_helper'

class AssetTest < Test::Unit::TestCase
  fixtures :attachments, :db_files, :users, :sites

  def test_should_count_correct_assets
    assert_equal 1, Asset.count
  end

  def test_should_show_user_avatar
    assert_equal attachments(:quentin), users(:quentin).avatar
  end

  #def test_should_clear_user_picture
  #  users(:quentin).picture = nil
  #  users(:quentin).save
  #  users(:quentin).reload
  #  assert_nil users(:quentin).picture
  #end

  def test_should_set_user_avatar
    users(:arthur).avatar = attachments(:quentin)
    attachments(:quentin).reload
    assert_nil   users(:quentin).avatar
    assert_equal attachments(:quentin), users(:arthur).avatar
  end

  def test_should_add_site_asset
    assert_difference sites(:first).assets, :length do
      sites(:first).assets << attachments(:site)
    end
  end
end
