class Admin::SettingsController < Admin::BaseController
  before_filter :find_and_sort_templates

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
