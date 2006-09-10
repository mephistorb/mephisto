class AccountController < ApplicationController
  include AuthenticatedSystem
  before_filter :login_from_cookie
  layout 'simple'

  def index
    render :action => 'login'
  end

  def login
    return unless request.post?
    self.current_user = User.authenticate_for(site, params[:login], params[:password])
    if logged_in?
      if params[:remember_me] == "1"
        self.current_user.remember_me
        cookies[:auth_token] = { :value => self.current_user.remember_token , :expires => self.current_user.remember_token_expires_at }
      end
      redirect_back_or_default(:controller => '/admin/overview', :action => 'index')
      flash[:notice] = "Logged in successfully"
    else
      flash[:error] = "Could not log you in. Are you sure your Login name and Password are correct?"
    end
  end

  def logout
    self.current_user = nil
    cookies.delete :auth_token
    reset_session
    flash[:notice] = "You have been logged out."
    redirect_back_or_default(dispatch_path)
  end
end
