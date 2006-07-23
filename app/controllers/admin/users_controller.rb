class Admin::UsersController < Admin::BaseController
  def index
    @users = User.find_with_deleted :all, :order => 'login'
    @enabled, @disabled = @users.partition { |u| u.deleted_at.nil? }
    @users = @enabled + @disabled
  end

  def show
    @user = User.find_by_login params[:id]
  end
  
  def new
    @user = User.new
  end

  def create
    @user = User.new params[:user]
    if @user.save
      flash[:notice] = "User created."
      redirect_to :action => 'index'
    else
      flash[:error] = "Save failed."
      render :action => 'new'
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

  def destroy
    @user = User.find params[:id]
    @user.destroy
    @user = User.find_with_deleted params[:id] # reload
  end

  def enable
    @user = User.find_with_deleted params[:id]
    @user.deleted_at = nil
    @user.save!
  end
end
