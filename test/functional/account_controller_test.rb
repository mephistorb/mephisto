require File.dirname(__FILE__) + '/../test_helper'
require_dependency 'account_controller'

# Re-raise errors caught by the controller.
class AccountController; def rescue_action(e) raise e end; end

class AccountControllerTest < Test::Unit::TestCase
  fixtures :users, :sites

  def setup
    @controller = AccountController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    
    # for testing action mailer
    # @emails = ActionMailer::Base.deliveries 
    # @emails.clear
  end

  def test_should_login_and_redirect
    post :login, :login => 'quentin', :password => 'quentin'
    assert session[:user]
    assert cookies['user']
    assert_redirected_to :controller => 'admin/overview', :action => 'index'
  end

  def test_should_fail_login_and_not_redirect
    post :login, :login => 'quentin', :password => 'bad password'
    assert_nil session[:user]
    assert_nil cookies['user']
    assert_response :success
  end

  def test_should_fail_login_for_disabled_user_and_not_redirect
    post :login, :login => 'aaron', :password => 'arthur'
    assert_nil session[:user]
    assert_nil cookies['user']
    assert_response :success
  end

  def test_should_logout
    login_as :quentin
    get :logout
    assert_nil session[:user]
    assert_redirected_to section_url
    assert_response :redirect
  end

  # Uncomment if you're activating new user accounts
  # 
  # def test_should_activate_user
  #   assert_nil User.authenticate('arthur', 'arthur')
  #   get :activate, :id => users(:arthur).activation_code
  #   assert_equal users(:arthur), User.authenticate('arthur', 'arthur')
  # end
  # 
  # def test_should_activate_user_and_send_activation_email
  #   get :activate, :id => users(:arthur).activation_code
  #   assert_equal 1, @emails.length
  #   assert(@emails.first.subject =~ /Your account has been activated/)
  #   assert(@emails.first.body    =~ /#{assigns(:user).login}, your account has been activated/)
  # end
  # 
  # def test_should_send_activation_email_after_signup
  #   create_user
  #   assert_equal 1, @emails.length
  #   assert(@emails.first.subject =~ /Please activate your new account/)
  #   assert(@emails.first.body    =~ /Username: quire/)
  #   assert(@emails.first.body    =~ /Password: quire/)
  #   assert(@emails.first.body    =~ /account\/activate\/#{assigns(:user).activation_code}/)
  # end

  protected
  def create_user(options = {})
    post :signup, :user => { :login => 'quire', :email => 'quire@example.com', 
                             :password => 'quire', :password_confirmation => 'quire' }.merge(options)
  end
end
