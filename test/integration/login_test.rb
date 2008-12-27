require File.dirname(__FILE__) + '/../test_helper'

class LoginTest < ActionController::IntegrationTest
  def setup
    @site = Site.make
    @user = User.make(:login => "sarah", :password => "password",
                      :admin => true, :password_confirmation => "password")
    assert User.authenticate_for(@site, "sarah", "password")
  end

  test "should log in with valid username and password" do
    visit "/admin"
    log_in_with "sarah", "password"
    assert_logged_in_as @user
  end

  test "should remember users when 'Remember me' is checked" do
    visit "/admin"
    log_in_with "sarah", "password", :remember_me => true
    assert_logged_in_as @user, :remembered => true
  end

  test "should fail to log in with invalid user" do
    visit "/admin"
    log_in_with "invalid", "password"
    assert_not_logged_in
  end

  test "should fail to log in with invalid password" do
    visit "/admin"
    log_in_with "sarah", "invalid"
    assert_not_logged_in
  end

  def log_in_with login, password, options={}
    options[:remember_me] ||= false

    fill_in "Login", :with => login
    fill_in "Password", :with => password
    if options[:remember_me]
      check "Remember me"
    else
      uncheck "Remember me"
    end
    click_button "Sign in"
  end

  def assert_logged_in_as user, options = {}
    options[:remembered] ||= false
    assert_equal @user.id, session[:user]
    if options[:remembered]
      @user.reload
      assert_equal @user.token, cookies['token']
    else
      assert_nil cookies['token']
    end
  end

  def assert_not_logged_in
    assert_nil session[:user]
    assert_nil cookies['token']
  end
end
