class Admin::TemplatesController < Admin::BaseController
  cache_sweeper :template_sweeper
  verify :params => :id, :only => [:edit, :update],
         :add_flash   => { :error => 'Template required' },
         :redirect_to => { :action => 'index' }
  verify :method => :post, :params => :template, :only => :update,
         :add_flash   => { :error => 'Template required' },
         :redirect_to => { :action => 'edit' }
         
  with_options :except => :index do |c|
    c.before_filter :find_templates_and_resources!
    c.before_filter :select_template
  end

  def index
    redirect_to :controller => 'design'
  end

  def update
    render :update do |page|
      page.call 'Flash.notice', 'Template updated successfully' if @tmpl.update_attributes(params[:template])
      page['flash-notice'].visual_effect(:highlight).visual_effect(:shake)
    end
  end

  protected
  # @template var clashes with ActionView instance, so use @tmpl
  # Selects all templates for sidebar
  # Create system template if it does not exist
  def select_template
    @tmpl   = @templates.detect { |t| t.filename == params[:id] }
    @tmpl ||= Template.find_or_create_by_filename(params[:id]) if Template.template_types.include?(params[:id].to_sym)
  end
end
