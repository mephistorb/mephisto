class AccountController < ApplicationController
  include AuthenticatedSystem
  layout 'simple'

  def index
    render :action => 'login'
  end

  def login
    return unless request.post?
    self.current_user = User.authenticate(params[:login], params[:password])
    if current_user
      redirect_back_or_default(:controller => '/admin/overview', :action => 'index')
      flash[:notice] = "Logged in successfully"
    else
      flash[:error] = "Could not log you in. Are you sure your Login name and Password are correct?"
    end
  end

  def logout
    self.current_user = nil
    flash[:notice] = "You have been logged out."
    redirect_back_or_default(:controller => 'mephisto', :action => 'list', :sections => [])
  end
end
