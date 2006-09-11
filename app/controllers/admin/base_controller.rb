class Admin::BaseController < ApplicationController
  include AuthenticatedSystem
  before_filter :login_from_cookie
  before_filter :login_required, :except => :feed

  def admin?
    logged_in? && current_user.admin? || current_user.site_admin?
  end
  
  helper_method :admin?

  protected
    def find_and_sort_templates
      @layouts, @templates = site.templates.partition { |t| t.dirname.to_s =~ /layouts$/ }
    end
end
