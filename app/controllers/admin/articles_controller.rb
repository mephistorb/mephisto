class Admin::ArticlesController < ApplicationController
  def index
    @articles = Article.find :all, :order => 'created_at DESC'
  end
end
