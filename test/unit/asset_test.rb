require File.dirname(__FILE__) + '/../test_helper'

class AssetTest < Test::Unit::TestCase
  fixtures :attachments, :db_files, :users, :sites

  def test_should_count_correct_assets
    assert_equal 1, Asset.count
  end

  def test_should_show_user_picture
    assert_equal attachments(:quentin), users(:quentin).picture
  end

  #def test_should_clear_user_picture
  #  users(:quentin).picture = nil
  #  users(:quentin).save
  #  users(:quentin).reload
  #  assert_nil users(:quentin).picture
  #end

  def test_should_set_user_picture
    users(:arthur).picture = attachments(:quentin)
    attachments(:quentin).reload
    assert_nil   users(:quentin).picture
    assert_equal attachments(:quentin), users(:arthur).picture
  end

  def test_should_add_site_asset
    assert_difference sites(:first).assets, :length do
      sites(:first).assets << attachments(:quentin)
      attachments(:quentin).reload and sites(:first).reload
      assert_nil   users(:quentin).picture
    end
  end
end
