class AccountController < ApplicationController
  include AuthenticatedSystem
  before_filter { |c| UserMailer.default_url_options[:host] = c.request.host_with_port }
  before_filter :protect_action, :except => [:index, :login, :activate]
  before_filter :login_from_cookie
  layout 'simple'

  protect_from_forgery

  def index
    render :action => 'login'
  end

  def login
    return unless request.post?
    self.current_user = User.authenticate_for(site, params[:login], params[:password])
    if logged_in?
      cookies[:token] = { :value => current_user.reset_token!, :expires => Time.now.utc+2.weeks, :http_only => true } if params[:remember_me] == "1"
      return redirect_back_or_default(default_url(self.current_user))
    end
    flash.now[:error] = "Could not log you in. Are you sure your Login name and Password are correct?"
  end

  def logout
    self.current_user = nil
    cookies.delete :token
    reset_session
    flash[:notice] = "You have been logged out."
    redirect_back_or_default(dispatch_path)
  end

  def forget
    if request.post? && @user = site.user_by_email(params[:email])
      flash[:notice] = "A temporary login email has been sent to '#{CGI.escapeHTML @user.email}'"
      @user.reset_token!
      UserMailer.deliver_forgot_password(@user)
    else
      flash[:error] = "I could not find an account with the email address '#{CGI.escapeHTML params[:email]}'. Did you type it correctly?"
    end
    redirect_to :action => 'login'
  end

  def activate
    self.current_user = site.user_by_token(params[:id])
    if logged_in?
      # TODO - See security comments on AuthenticatedSystem#login_from_cookie.
      ActiveRecord::Base.with_writable_records do
        current_user.reset_token!
      end
    else
      flash[:error] = "Invalid token.  Try resending your forgotten password request."
    end
    redirect_to(logged_in? ? {:controller => 'admin/users', :action => 'show', :id => current_user} : {:action => 'login'})
  end

  protected
    def default_url(user)
      # If the user can log in then they have permission to act in the admin section (non-admins can post, admins can admin the site)
      logged_in? ? url_for(:controller => '/admin/overview', :action => 'index') : dispatch_url(:path => [])
    end
end
