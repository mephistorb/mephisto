class Admin::DesignController < Admin::BaseController
  def create
    if params[:filename].blank? || params[:data].blank?
      render :action => 'index'
      return
    end

    if params[:filename] =~ /\.(css|js)$/i
      @resource = site.resources.write params[:filename], params[:data]
      redirect_to :controller => 'resources', :action => 'edit', :filename => @resource.basename.to_s
    else
      @tmpl = site.templates.write params[:filename], params[:data]
      redirect_to :controller => 'templates', :action => 'edit', :filename => @tmpl.basename.to_s
    end
  end
  
  protected
    alias authorized? admin?
end
