class Admin::TemplatesController < ApplicationController
  before_filter :select_template, :except => :index
  verify :params => :id, :only => [:edit, :update],
         :add_flash   => { :error => 'Template required' },
         :redirect_to => { :action => 'index' }
  verify :method => :post, :params => :template, :only => :update,
         :add_flash   => { :error => 'Template required' },
         :redirect_to => { :action => 'edit' }

  def update
    if @tmpl.update_attributes(params[:template])
      flash[:notice] = "#{@tmpl.name} updated."
      redirect_to :action => 'edit', :id => @tmpl
    else
      render :action => 'edit'
    end
  end

  protected
  def select_template
    @tmpl = Template.find_by_name(params[:id])
  end
end
