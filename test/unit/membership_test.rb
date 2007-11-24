require File.dirname(__FILE__) + '/../test_helper'

# DEPRECATED, see spec/models/membership_spec.rb

class MembershipTest < Test::Unit::TestCase
  fixtures :memberships, :users, :sites

  def test_should_find_user_sites
    assert_models_equal [sites(:hostess), sites(:first)].collect(&:id).sort, users(:arthur).sites.collect(&:id).sort
  end
  
  def test_should_find_site_members
    assert_models_equal [users(:arthur), users(:quentin), users(:ben)].collect(&:id).sort, sites(:first).members.collect(&:id).sort
  end
  
  def test_should_find_site_admins
    assert_models_equal [users(:arthur), users(:quentin)].collect(&:id).sort, sites(:first).admins.collect(&:id).sort
    assert_models_equal [users(:quentin)], sites(:hostess).admins
  end
  
  def test_should_find_all_site_users
    assert_models_equal [users(:arthur), users(:quentin), users(:ben)].collect(&:id).sort, User.find_all_by_site(sites(:first)).collect(&:id).sort
    assert_models_equal [users(:arthur), users(:quentin), users(:ben)].collect(&:id).sort, sites(:first).users.collect(&:id).sort
  end
  
  def test_should_find_all_site_users_with_deleted
    assert_models_equal [User.find_with_deleted(3), users(:arthur), users(:quentin), users(:ben)].collect(&:id).sort, User.find_all_by_site_with_deleted(sites(:first)).collect(&:id).sort
    assert_models_equal [User.find_with_deleted(3), users(:arthur), users(:quentin), users(:ben)].collect(&:id).sort, sites(:first).users_with_deleted.collect(&:id).sort
  end
end
