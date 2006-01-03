class Admin::ArticlesController < Admin::BaseController
  before_filter :set_default_tag_ids,        :only => [:create, :update]
  before_filter :clear_published_at_fields!, :only => [:create, :update]

  def index
    @tags     = Tag.find :all
    @article  = Article.new
    @articles = Article.find :all, :order => 'articles.created_at DESC', :conditions => 'article_id IS NULL', :include => :user
  end

  def create
    @article = current_user.articles.create params[:article]
  end

  def edit
    @tags    = Tag.find :all
    @article = Article.find(params[:id])
  end

  def update
    @article = Article.find(params[:id])
    if @article.update_attributes(params[:article])
      redirect_to :action => 'index'
    else
      @tags = Tag.find :all
      render :action => 'edit'
    end
  end

  protected
  def set_default_tag_ids
    params[:article][:tag_ids] ||= []
  end

  def clear_published_at_fields!
    return if params[:article_published]
    params[:article].keys.select { |k| k =~ /^published_at/ }.each { |k| params[:article].delete(k) }
    params[:article][:published_at] = nil
  end
end
