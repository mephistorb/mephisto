class Admin::SettingsController < Admin::BaseController
  def update
    if site.update_attributes params[:site]
      redirect_to :action => 'index'
    else
      render :action => 'index'
    end
  end
  
  protected
    alias authorized? admin?
end
