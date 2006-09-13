class Admin::SectionsController < Admin::BaseController
  cache_sweeper :section_sweeper, :except => :index
  before_filter :find_and_sort_templates,   :only => [:index, :edit]
  before_filter :find_and_reorder_sections, :only => [:index, :edit]
  before_filter :find_section,              :only => [:destroy, :update, :order]
  clear_empty_templates_for :section, :template, :layout, :archive_template, :only => [:create, :update]

  def index
    @section = site.sections.build
  end

  def create
    @section = site.sections.create(params[:section])
  end

  def destroy
    @section.destroy
    render :update do |page|
      page.visual_effect :drop_out, "section-#{params[:id]}"
    end
  end

  def update
    @section.update_attributes params[:section]
  end

  def order
    @section.order! params[:article_ids]
    render :nothing => true
  end

  protected
    def find_and_reorder_sections
      @article_count = site.sections.articles_count
      @sections      = site.sections.find :all
      @sections.each do |s|
        @home    = s if s.home?
        @section = s if params[:id].to_s == s.id.to_s
      end
      @sections.delete  @home
      @sections.unshift @home
    end
    
    def find_section
      @section = site.sections.find params[:id]
    end

    alias authorized? admin?
end
