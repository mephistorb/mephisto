require File.dirname(__FILE__) + '/../test_helper'

class MembershipTest < Test::Unit::TestCase
  fixtures :memberships, :users, :sites

  def test_should_find_user_sites
    assert_models_equal [sites(:hostess), sites(:first)], users(:arthur).sites
  end
  
  def test_should_find_site_members
    assert_models_equal [users(:arthur), users(:quentin)], sites(:first).members
  end
  
  def test_should_find_site_admins
    assert_models_equal [users(:arthur), users(:quentin)], sites(:first).admins
    assert_models_equal [users(:quentin)], sites(:hostess).admins
  end
  
  def test_should_find_all_site_users
    assert_models_equal [users(:arthur), users(:quentin)], User.find_all_by_site(sites(:first))
    assert_models_equal [users(:arthur), users(:quentin)], sites(:first).users
  end
  
  def test_should_find_all_site_users_with_deleted
    assert_models_equal [User.find_with_deleted(3), users(:arthur), users(:quentin)], User.find_all_by_site_with_deleted(sites(:first))
    assert_models_equal [User.find_with_deleted(3), users(:arthur), users(:quentin)], sites(:first).users_with_deleted
  end
end
