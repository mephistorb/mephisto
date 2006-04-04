class Admin::SettingsController < Admin::BaseController
  before_filter :site
  
  def update
    if site.update_attributes params[:site]
      redirect_to :action => 'index'
    else
      render :action => 'index'
    end
  end
end
