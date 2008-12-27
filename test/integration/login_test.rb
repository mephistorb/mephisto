require File.dirname(__FILE__) + '/../test_helper'
#require 'webrat/selenium'

class LoginTest < ActionController::IntegrationTest
  def setup
    @site = Site.make
    @user = User.make(:login => "sarah", :password => "password",
                      :admin => true, :password_confirmation => "password")
    visit "/admin"
  end

  test "should log in with valid username and password" do
    log_in_with "sarah", "password"
    assert_logged_in_as @user
  end

  test "should remember users when 'Remember me' is checked" do
    log_in_with "sarah", "password", :remember_me => true
    assert_logged_in_as @user, :remembered => true
  end

  test "should fail to log in with invalid user" do
    log_in_with "invalid", "password"
    assert_not_logged_in
    assert_equal('Could not log you in. Are you sure your Login name ' +
                 'and Password are correct?', flash[:error])
  end

  test "should fail to log in with invalid password" do
    log_in_with "sarah", "invalid"
    assert_not_logged_in
  end

  test "should reset password if given valid email" do
    @emails = ActionMailer::Base.deliveries 
    @emails.clear

    assert_difference @emails, :size, 1 do
      click_link "reset password"
      fill_in "email", :with => @user.email
      click_button "Reset"
    end
    assert_equal @user.email, @emails.first.to.first
    assert_not_logged_in

    # Extract the activation URL from the e-mail.
    @emails.first.body =~ %r{(http://[^ ]*)}
    activation_url = $1
    assert_not_nil activation_url

    visit activation_url
    assert_logged_in_as @user

    fill_in "Password", :with => "newpass"
    fill_in "Password confirmation", :with => "newpass"
    click_button "Save my profile"

    assert User.authenticate_for(@site, @user.login, "newpass")
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
