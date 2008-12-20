class Admin::DesignController < Admin::BaseController
  before_filter :find_theme

  def create
    if params[:filename].blank? || params[:data].blank?
      render :action => 'index'
      return
    end

    if params[:filename] =~ /\.(css|js)\z/i
      @resource = @theme.resources.write params[:filename], params[:data]
      redirect_to url_for_theme(:controller => 'resources', :action => 'edit', :filename => @resource.basename.to_s)
    else
      @tmpl = @theme.templates.write params[:filename], params[:data]
      redirect_to url_for_theme(:controller => 'templates', :action => 'edit', :filename => @tmpl.basename.to_s)
    end
  end
  
  protected
    alias authorized? admin?
    
    def find_theme
      @theme = params[:theme] ? site.themes[params[:theme]] : site.theme
    end
    
    def current_theme?
       site.theme.base_path == @theme.base_path
    end
    
    def url_for_theme(options)
      @theme.current? ? options : options.update(:theme => @theme.name)
    end
    helper_method :url_for_theme
end
