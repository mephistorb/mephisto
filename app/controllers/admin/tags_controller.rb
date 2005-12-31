class Admin::TagsController < ApplicationController
  def index
    @tag  = Tag.new
    @tags = Tag.find :all
  end

  def create
    @tag = Tag.create(params[:tag])
  end
end
