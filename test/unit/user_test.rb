require File.dirname(__FILE__) + '/../test_helper'

class UserTest < Test::Unit::TestCase
  fixtures :users, :sites, :memberships

  def test_should_create_user
    assert create_user.valid?
  end

  def test_should_require_login
    u = create_user(:login => nil)
    assert u.errors.on(:login)
  end

  def test_should_require_password
    u = create_user(:password => nil)
    assert u.errors.on(:password)
  end

  def test_should_require_password_confirmation
    u = create_user(:password_confirmation => nil)
    assert u.errors.on(:password_confirmation)
  end

  def test_should_require_email
    u = create_user(:email => nil)
    assert u.errors.on(:email)
  end

  def test_should_reset_password
    users(:quentin).update_attributes(:password => 'new password', :password_confirmation => 'new password')
    assert_equal users(:quentin), User.authenticate_for(sites(:first), 'quentin', 'new password')
  end

  def test_should_not_rehash_password
    users(:quentin).update_attribute(:login, 'quentin2')
    assert_equal users(:quentin), User.authenticate_for(sites(:first), 'quentin2', 'test')
  end

  def test_should_authenticate_user_admin
    [:first, :hostess, :garden].each do |s|
      assert_equal users(:quentin), User.authenticate_for(sites(s), 'quentin', 'test'), "Unable to login to site: #{s}"
    end
  end

  def test_should_find_admin_by_id
    [:first, :hostess, :garden].each do |s|
      user = User.find_by_site(sites(s), users(:quentin).id)
      assert_equal users(:quentin), user, "Unable to login to site: #{s}"
    end
  end

  def test_should_authenticate_member
    first_member   = User.authenticate_for(sites(:first), 'arthur', 'test')
    hostess_member = User.authenticate_for(sites(:hostess), 'arthur', 'test')
    assert_equal users(:arthur), first_member
    assert_equal users(:arthur), hostess_member
    assert  first_member.site_admin?
    assert !hostess_member.site_admin?
  end
  
  def test_should_find_member_by_site
    first_member   = User.find_by_site(sites(:first), users(:arthur).id)
    hostess_member = User.find_by_site(sites(:hostess), users(:arthur).id)
    assert_equal users(:arthur), first_member
    assert_equal users(:arthur), hostess_member
    assert  first_member.site_admin?
    assert !hostess_member.site_admin?
  end

  def test_should_not_authenticate_for_non_member
    assert_nil User.authenticate_for(sites(:garden), 'arthur', 'test')
  end

  def test_should_not_authenticate_expired
    assert_nil User.authenticate_for(sites(:first), 'aaron', 'test')
  end

  def test_should_find_non_admin_member_of_site
    assert_equal users(:ben), User.authenticate_for(sites(:first), 'ben', 'test')
  end

  def test_should_find_member_by_token
    assert_equal users(:quentin), User.find_by_token(sites(:first), users(:quentin).token)
  end

  def test_should_not_find_member_by_expired_token
    assert_nil User.find_by_token(sites(:first), users(:arthur).token)
  end

  def test_should_not_find_member_by_token_in_wrong_site
    memberships(:quentin_first).destroy
    users(:quentin).update_attribute :admin, false
    assert_nil User.find_by_token(sites(:first), users(:quentin).token)
  end

  def test_should_find_member_by_email
    assert_equal users(:quentin), User.find_by_email(sites(:first), users(:quentin).email)
  end

  def test_should_not_find_member_by_email_in_wrong_site
    memberships(:arthur_first).destroy
    assert_nil User.find_by_email(sites(:first), users(:arthur).email)
  end

  def test_should_allow_empty_filter
    users(:quentin).update_attribute :filter, ''
    assert_equal '', users(:quentin).reload.filter
  end

  def test_should_find_admins
    assert_models_equal [users(:quentin)], User.find_admins(:all)
  end

  protected
    def create_user(options = {})
      User.create({ :login => 'quire', :email => 'quire@example.com', :password => 'quire', :password_confirmation => 'quire' }.merge(options))
    end
end
