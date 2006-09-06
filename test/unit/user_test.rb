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
    assert_equal users(:quentin), User.authenticate_for(sites(:first), 'quentin2', 'quentin')
  end

  def test_should_authenticate_user_admin
    [:first, :hostess, :garden].each do |s|
      assert_equal users(:quentin), User.authenticate_for(sites(s), 'quentin', 'quentin'), "Unable to login to site: #{s}"
    end
  end

  def test_should_authenticate_member
    assert_equal users(:arthur), User.authenticate_for(sites(:first), 'arthur', 'arthur')
    assert_equal users(:arthur), User.authenticate_for(sites(:hostess), 'arthur', 'arthur')
  end
  
  def test_should_not_authenticate_expired
    assert_nil User.authenticate_for(sites(:first), 'aaron', 'aaron')
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
