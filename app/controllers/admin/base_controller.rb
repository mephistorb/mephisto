class Admin::BaseController < ApplicationController
  include AuthenticatedSystem
  before_filter :login_from_cookie
  before_filter :login_required, :except => :feed

  def admin?
    logged_in? && current_user.admin? || current_user.site_admin?
  end
  
  helper_method :admin?
end
