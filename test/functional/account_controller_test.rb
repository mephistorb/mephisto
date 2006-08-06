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
    assert_redirected_to :controller => 'admin/overview', :action => 'index'
  end

  def test_should_fail_login_and_not_redirect
    post :login, :login => 'quentin', :password => 'bad password'
    assert_nil session[:user]
    assert_response :success
  end

  def test_should_fail_login_for_disabled_user_and_not_redirect
    post :login, :login => 'aaron', :password => 'arthur'
    assert_nil session[:user]
    assert_response :success
  end

  def test_should_logout
    login_as :quentin
    get :logout
    assert_nil session[:user]
    assert_redirected_to section_url
    assert_response :redirect
  end

  def test_should_remember_me
    post :login, :login => 'quentin', :password => 'quentin', :remember_me => "1"
    assert_not_nil @response.cookies["auth_token"]
  end

  def test_should_not_remember_me
    post :login, :login => 'quentin', :password => 'quentin', :remember_me => "0"
    assert_nil cookies[:auth_token]
  end
  
  def test_should_delete_token_on_logout
    login_as :quentin
    get :logout
    assert_equal @response.cookies["auth_token"], []
  end

  def test_should_login_with_cookie
    users(:quentin).remember_me
    @request.cookies["auth_token"] = cookie_for(:quentin)
    get :index
    assert @controller.send(:logged_in?)
  end

  def test_should_fail_cookie_login
    users(:quentin).remember_me
    users(:quentin).update_attribute :remember_token_expires_at, 5.minutes.ago.utc
    @request.cookies["auth_token"] = cookie_for(:quentin)
    get :index
    assert !@controller.send(:logged_in?)
  end

  def test_should_fail_cookie_login
    users(:quentin).remember_me
    @request.cookies["auth_token"] = auth_token('invalid_auth_token')
    get :index
    assert !@controller.send(:logged_in?)
  end

  protected
    def auth_token(token)
      CGI::Cookie.new('name' => 'auth_token', 'value' => token)
    end
    
    def cookie_for(user)
      auth_token users(user).remember_token
    end

    def create_user(options = {})
      post :signup, :user => { :login => 'quire', :email => 'quire@example.com', 
                               :password => 'quire', :password_confirmation => 'quire' }.merge(options)
    end
end
