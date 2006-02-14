class Admin::UsersController < Admin::BaseController
  def index
    @users = User.find :all, :order => 'login'
  end

  def show
    @user = User.find_by_login params[:id]
  end

  def update
    @user            = User.find_by_login params[:id]
    @user.attributes = params[:user]
    @user.build_avatar :uploaded_data => params[:avatar]
    if @user.save
      flash[:notice] = "Profile updated."
      redirect_to :action => 'show', :id => @user
    else
      flash[:error] = "Save failed."
      render :action => 'show'
    end
  end
end
