class Admin::PagesController < Admin::BaseController
  cache_sweeper :section_sweeper
  verify :params => :id, :only => [:edit, :update, :order],
         :add_flash   => { :error => 'Section required' },
         :redirect_to => { :action => 'index' }
  verify :method => :post, :params => :section, :only => :update,
         :add_flash   => { :error => 'Section required' },
         :redirect_to => { :action => 'edit' }
  before_filter :select_section, :except => :index

  def order
    Article.transaction do
      params[:articles].each_with_index do |pos, index|
        @section.assigned_sections.detect { |t| t.article_id.to_s == pos }.update_attributes(:position => index)
      end
      @section.save # kick off the sweeper!
    end
    render :nothing => true
  end

  def update
    saved = @section.update_attributes(params[:section])
    return if request.xhr?
    if saved
      flash[:notice] = "#{@section.name} updated."
      redirect_to :action => 'edit', :id => @section
    else
      render :action => 'edit'
    end
  end

  protected
  def select_section
    @section = Section.find_paged { Section.find_by_name(params[:id]) }
  end
end
