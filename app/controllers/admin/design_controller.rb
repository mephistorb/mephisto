class Admin::DesignController < Admin::BaseController
  verify :method => :post, :params => [:resource_type, :resource], :only => :create,
   :redirect_to => { :action => 'index' }
  before_filter :find_templates_and_resources!

  def index
    @resource = Resource.new
  end

  def create
    @resource = case params[:resource_type]
      when /css/i
        Resource.create params[:resource].merge(:content_type => 'text/css')
      when /javascript/i
        Resource.create params[:resource].merge(:content_type => 'text/javascript')
      else
        Template.create params[:resource]
    end
    
    if @resource.new_record?
      render :action => 'index'
    else
      redirect_to :controller => @resource.class.to_s.tableize, :action => 'edit', :id => @resource.to_param
    end
  end
end
