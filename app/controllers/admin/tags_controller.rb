class Admin::TagsController < ApplicationController
  in_place_edit_for :tag, :name
  
  def index
    @tag  = Tag.new
    @tags = Tag.find :all
  end

  def create
    @tag = Tag.create(params[:tag])
  end

  def destroy
    Tag.find(params[:id]).destroy
  end
end
