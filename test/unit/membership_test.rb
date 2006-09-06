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
end
