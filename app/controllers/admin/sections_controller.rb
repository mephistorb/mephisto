class Admin::SectionsController < Admin::BaseController
  cache_sweeper :section_sweeper, :except => :index
  before_filter :find_and_sort_templates,   :only => [:index, :edit]
  before_filter :find_and_reorder_sections, :only => [:index, :edit]
  before_filter :find_section,              :only => [:destroy, :update, :order]
  before_filter :preprocess_section_params, :only => [:create, :update]

  def index
    @section  = Section.new
  end

  def create
    @section = Section.create(params[:section])
  end

  def destroy
    @section.destroy
    render :update do |page|
      page.visual_effect :drop_out, "section-#{params[:id]}"
    end
  end

  def update
    @section.update_attributes params[:section]
    render :update do |page|
      page.replace_html "section_#{params[:id]}", :partial => 'section'
      page.visual_effect :highlight, "section_#{params[:id]}"
    end
  end

  def order
    @section.order! params[:article_ids]
    render :nothing => true
  end

  protected
  def find_and_sort_templates
    @layouts, @templates = Template.find_custom.partition { |t| t.layout? }
  end

  def find_and_reorder_sections
    @article_count = Section.articles_count
    @sections      = Section.find :all
    @sections.each do |s|
      @home    = s if s.name.downcase == 'home'
      @section = s if params[:id].to_s == s.id.to_s
    end
    @sections.delete  @home
    @sections.unshift @home
  end

  def find_section
    @section = Section.find params[:id]
  end

  def preprocess_section_params
    params[:section][:template] = nil if params[:section][:template] == '0'
    params[:section][:layout]   = nil if params[:section][:layout]   == '0'
  end
end
