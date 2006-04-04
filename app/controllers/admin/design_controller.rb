class Admin::DesignController < Admin::BaseController
  verify :method => :post, :params => [:resource_type, :resource], :only => :create,
   :redirect_to => { :action => 'index' }
  before_filter :find_templates_and_resources!

  def index
    @resource = site.resources.build
  end

  def create
    @resource = case params[:resource_type]
      when /css/i
        site.resources.create params[:resource].merge(:content_type => 'text/css')
      when /javascript/i
        site.resources.create params[:resource].merge(:content_type => 'text/javascript')
      else
        site.templates.create params[:resource]
    end

    if @resource.new_record?
      render :action => 'index'
    else
      redirect_to :controller => @resource.class.to_s.tableize, :action => 'edit', :id => @resource.to_param
    end
  end
end
