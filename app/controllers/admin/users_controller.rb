class Admin::UsersController < Admin::BaseController
  def index
    @users = User.find :all, :order => 'login'
  end

  def show
    @user = User.find_by_login params[:id]
  end
end
