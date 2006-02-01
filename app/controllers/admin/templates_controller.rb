class Admin::TemplatesController < Admin::BaseController
  cache_sweeper :template_sweeper
  verify :params => :id, :only => [:edit, :update],
         :add_flash   => { :error => 'Template required' },
         :redirect_to => { :action => 'index' }
  verify :method => :post, :params => :template, :only => :update,
         :add_flash   => { :error => 'Template required' },
         :redirect_to => { :action => 'edit' }
  before_filter :select_template, :except => :index

  def update
    saved = @tmpl.update_attributes(params[:template])
    return if request.xhr?
    if saved
      flash[:notice] = "#{@tmpl.name} updated."
      redirect_to :action => 'edit', :id => @tmpl
    else
      render :action => 'edit'
    end
  end

  protected
  def select_template
    @tmpl = Template.template_types.include?(params[:id].to_sym) ? Template.find_or_create_by_name(params[:id]) : nil
  end
end
