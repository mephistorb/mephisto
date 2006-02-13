class Admin::ResourcesController < Admin::BaseController
  cache_sweeper :asset_sweeper
  verify :params => :id, :only => [:edit, :update],
         :add_flash   => { :error => 'Resource required' },
         :redirect_to => { :controller => 'design', :action => 'index' }
  verify :method => :post, :params => :resource, :only => :update,
         :add_flash   => { :error => 'Resource required' },
         :redirect_to => { :action => 'edit' }
  verify :method => :post, :params => :resource, :only => :upload,
         :add_flash   => { :error => 'Resource required' },
         :redirect_to => { :controller => 'design', :action => 'index' }
         
  with_options :except => :index do |c|
    c.before_filter :find_templates_and_resources!
    c.before_filter :select_resource
  end

  def index
    redirect_to :controller => 'design'
  end

  def update
    render :update do |page|
      page.call 'Flash.notice', 'Resource updated successfully' if @resource.update_attributes(params[:resource])
    end
  end

  def upload
    @resource = Resource.new params[:resource]
    if @resource.image? and @resource.save
      flash[:notice] = "'#{@resource.filename}' was uploaded successfully."
    else
      flash[:error]  = "A bad or nonexistant image was uploaded."
    end
    redirect_to :controller => 'design', :action => 'index'
  end
  
  def remove
    render :update do |page|
      page.visual_effect :fade, "image-#{params[:id]}", :duration => 0.3 if Resource.find(params[:id]).destroy
    end
  end

  protected
  def select_resource
    @resource = @resources.detect { |r| r.id.to_s == params[:id] }
  end
end
