class Admin::UsersController < Admin::BaseController
  MEMBER_ACTIONS = %w(show update).freeze unless const_defined?(:MEMBER_ACTIONS)
  before_filter :find_all_users, :only => [:index, :show, :new]
  before_filter :find_user,      :only => [:show, :update, :enable]
  def index
    @enabled, @disabled = @users.partition { |u| u.deleted_at.nil? }
    @users = @enabled + @disabled
  end
  
  def new
    @user  = User.new
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
    render :update do |page|
      if @user.update_attributes(params[:user])
        page.call 'Flash.notice', 'Profile updated.'
      else
        page.call 'Flash.errors', "Save failed: #{@user.errors.full_messages.to_sentence}"
      end
    end
  end

  def destroy
    @user = site.user(params[:id])
    @user.destroy
    @user = site.user_with_deleted(params[:id]) # reload
  end

  def enable
    @user.deleted_at = nil
    @user.save!
  end
  
  protected
    def find_all_users
      @users = site.users_with_deleted
    end
    
    def find_user
      @user = site.user_with_deleted(params[:id])
    end
    
    def authorized?
      logged_in? && (admin? || (current_user.id.to_s == params[:id] && MEMBER_ACTIONS.include?(action_name)))
    end
end
