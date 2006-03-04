class Admin::UsersController < Admin::BaseController
  def index
    @users = User.find :all, :order => 'login'
  end

  def show
    @user = User.find_by_login params[:id]
  end

  def create
    @user = User.new params[:user]
    if @user.save
      flash[:notice] = "User created."
      redirect_to :action => 'index'
    else
      flash[:error] = "Save failed."
      render :action => 'show'
    end
  end

  def update
    @user = User.find_by_login params[:id]
    if @user.update_attributes params[:user]
      flash[:notice] = "Profile updated."
      redirect_to :action => 'show', :id => @user
    else
      flash[:error] = "Save failed."
      render :action => 'show'
    end
  end
  
  def new
    @user = User.new
  end
  
end
