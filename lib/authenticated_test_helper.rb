module AuthenticatedTestHelper
  # Sets the current user in the session from the user fixtures.
  def login_as(user)
    @request.session[:user] = user ? users(user).id : nil
  end

  def login_with_cookie_as(user)
    @request.cookies['user'] = user ? CGI::Cookie.new( 
      'name'   => 'user',
      'value'   => users(user).activation_code,
      'expires' => 2.weeks.from_now,
      'path'    => '/',
      'domain'  => 'example.com'
    ) : nil
  end

  # Assert the block redirects to the login
  # 
  #   assert_requires_login(:bob) { get :edit, :id => 1 }
  #
  def assert_requires_login(user = nil, &block)
    login_as(user) if user
    block.call
    assert_redirected_to :controller => 'account', :action => 'login'
  end

  # Assert the block accepts the login
  # 
  #   assert_accepts_login(:bob) { get :edit, :id => 1 }
  #
  # Accepts anonymous logins:
  #
  #   assert_accepts_login { get :list }
  #
  def assert_accepts_login(user = nil, &block)
    login_as(user) if user
    block.call
    assert_response :success
  end
end