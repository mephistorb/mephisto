class Admin::ResourcesController < Admin::BaseController
  verify :params => :filename, :only => [:edit, :update],
         :add_flash   => { :error => 'Resource required' },
         :redirect_to => { :controller => 'design', :action => 'index' }
  verify :method => :post, :params => :data, :only => :update,
         :add_flash   => { :error => 'Resource required' },
         :redirect_to => { :action => 'edit' }
  verify :method => :post, :params => :resource, :only => :upload,
         :add_flash   => { :error => 'Resource required' },
         :redirect_to => { :controller => 'design', :action => 'index' }
  
  def index
    redirect_to :controller => 'design'
  end

  def edit
    @resource = site.resources[params[:filename]]
  end

  def update
    site.resources.write params[:filename], params[:data]
    self.class.expire_page('/' << site.resources[params[:filename]].relative_path_from(site.attachment_path).to_s)
    render :update do |page|
      page.call 'Flash.notice', 'Resource updated successfully'
    end
  end

  def upload
    if params[:resource] && Asset.image?(params[:resource].content_type.strip) && (1..1.megabyte).include?(params[:resource].size)
      @resource = site.resources.write File.basename(params[:resource].original_filename), params[:resource].read
      flash[:notice] = "'#{@resource.basename}' was uploaded successfully."
    else
      flash[:error]  = "A bad or nonexistant image was uploaded."
    end
    redirect_to :controller => 'design', :action => 'index'
  end
  
  def remove
    @resource = site.resources[params[:filename]]
    render :update do |page|
      @resource.unlink if @resource.file?
      page.visual_effect :fade, params[:context], :duration => 0.3
    end
  end
  
  protected
    alias authorized? admin?
end
