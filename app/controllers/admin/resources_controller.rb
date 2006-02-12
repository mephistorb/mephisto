class Admin::ResourcesController < Admin::BaseController
  #cache_sweeper :template_sweeper
  verify :params => :id, :only => [:edit, :update],
         :add_flash   => { :error => 'Resource required' },
         :redirect_to => { :action => 'index' }
  verify :method => :post, :params => :template, :only => :update,
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
    saved = @resource.update_attributes(params[:resource])
    case
      when request.xhr?
        render :partial => 'form', :locals => { :template => @resource }
      
      when saved
        flash[:notice] = "#{@tmpl.filename} updated."
        redirect_to :action => 'edit', :id => @tmpl
    
      else
        render :action => 'edit'
    end
  end

  protected
  def select_resource
    @resource = @resources.detect { |r| r.id.to_s == params[:id] }
  end
end
