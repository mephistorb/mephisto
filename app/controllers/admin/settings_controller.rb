class Admin::SettingsController < Admin::BaseController
  before_filter :current_site
  def update
    if current_site.update_attributes params[:current_site]
      redirect_to :action => 'index'
    else
      render :action => 'index'
    end
  end
end
