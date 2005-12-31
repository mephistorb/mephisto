class Admin::TemplatesController < ApplicationController
  before_filter :select_templates
  verify :params => :id, :only => [:edit, :update],
         :add_flash   => { :error => 'Template required' },
         :redirect_to => { :action => 'index' }
  verify :method => :post, :params => :template, :only => :update,
         :add_flash   => { :error => 'Template required' },
         :redirect_to => { :action => 'edit' }

  def update
    if @tmpl.update_attributes(params[:template])
      flash[:notice] = "#{@tmpl.name} updated."
      redirect_to :action => 'edit'
    else
      render :action => 'edit'
    end
  end

  protected
  def select_templates
    @templates = Template.find :all
    @tmpl      = @templates.find { |t| t.id.to_s == params[:id] } if params[:id]
  end
end
