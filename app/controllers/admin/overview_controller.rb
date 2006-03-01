class Admin::OverviewController < Admin::BaseController
  before_filter :current_site
  
  def index
    @users = User.find(:all)
  end
  
end
