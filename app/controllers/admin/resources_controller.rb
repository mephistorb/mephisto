class Admin::ResourcesController < Admin::BaseController
  #cache_sweeper :template_sweeper
  verify :params => :id, :only => [:edit, :update],
         :add_flash   => { :error => 'Resource required' },
         :redirect_to => { :action => 'index' }
  verify :method => :post, :params => :resource, :only => :update,
         :add_flash   => { :error => 'Resource required' },
         :redirect_to => { :action => 'edit' }
         
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
    @resource = Resource.create params[:resource]
    flash[:notice] = "'#{@resource.filename}' was uploaded successfully."
    redirect_to :controller => 'design', :action => 'index'
  end

  protected
  def select_resource
    @resource = @resources.detect { |r| r.id.to_s == params[:id] }
  end
end
