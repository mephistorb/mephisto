class Admin::SectionsController < Admin::BaseController
  cache_sweeper :section_sweeper, :except => :index

  def index
    @section   = Section.new
    @sections = Section.find :all
  end

  def create
    @section = Section.create(params[:section])
  end

  def destroy
    Section.find(params[:id]).destroy
    render :update do |page|
      page.visual_effect :drop_out, "section_#{params[:id]}"
    end
  end

  def update
    (@section = Section.find(params[:id])).update_attributes params[:section]
    render :update do |page|
      page.replace_html "section_#{params[:id]}", :partial => 'section'
      page.visual_effect :highlight, "section_#{params[:id]}"
    end
  end
end
