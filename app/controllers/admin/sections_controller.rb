class Admin::SectionsController < Admin::BaseController
  cache_sweeper :section_sweeper, :except => :index
  before_filter :find_and_sort_templates,   :only => [:index, :edit]
  before_filter :find_and_reorder_sections, :only => [:index, :edit]
  before_filter :preprocess_section_params, :only => [:create, :update]

  def index
    @section  = Section.new
  end

  def edit
    @section = Section.find(params[:id])
  end

  def create
    @section = Section.create(params[:section])
  end

  def destroy
    Section.find(params[:id]).destroy
    render :update do |page|
      page.visual_effect :drop_out, "section-#{params[:id]}"
    end
  end

  def update
    (@section = Section.find(params[:id])).update_attributes params[:section]
    render :update do |page|
      page.replace_html "section_#{params[:id]}", :partial => 'section'
      page.visual_effect :highlight, "section_#{params[:id]}"
    end
  end

  protected
  def find_and_sort_templates
    @layouts, @templates = Template.find_custom.partition { |t| t.layout? }
  end

  def find_and_reorder_sections
    @sections = Section.find :all
    @home     = @sections.detect { |s| s.name.downcase == 'home' }
    @sections.delete  @home
    @sections.unshift @home
  end

  def preprocess_section_params
    params[:section][:template] = nil if params[:section][:template] == '0'
    params[:section][:layout] = nil   if params[:section][:layout]   == '0'
  end
end
