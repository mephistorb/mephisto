class Admin::TagsController < Admin::BaseController  
  def index
    @tag  = Tag.new
    @tags = Tag.find :all
  end

  def create
    @tag = Tag.create(params[:tag])
  end

  def destroy
    Tag.find(params[:id]).destroy
    render :update do |page|
      page.visual_effect :drop_out, "tag_#{params[:id]}"
    end
  end

  def update
    (@tag = Tag.find(params[:id])).update_attributes params[:tag]
    render :update do |page|
      page.replace_html "tag_#{params[:id]}", :partial => 'tag'
      page.visual_effect :highlight, "tag_#{params[:id]}"
    end
  end
end
