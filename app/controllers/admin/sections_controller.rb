class Admin::SectionsController < Admin::BaseController
  cache_sweeper :category_sweeper, :except => :index

  def index
    @section   = Section.new
    @sections = Section.find :all
  end

  def create
    @category = Category.create(params[:category])
  end

  def destroy
    Category.find(params[:id]).destroy
    render :update do |page|
      page.visual_effect :drop_out, "category_#{params[:id]}"
    end
  end

  def update
    (@category = Category.find(params[:id])).update_attributes params[:category]
    render :update do |page|
      page.replace_html "category_#{params[:id]}", :partial => 'category'
      page.visual_effect :highlight, "category_#{params[:id]}"
    end
  end
end
