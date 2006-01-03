class Admin::ArticlesController < Admin::BaseController
  before_filter :set_default_tag_ids, :only => [:create, :update]

  def index
    @tags     = Tag.find :all
    @article  = Article.new
    @articles = Article.find :all, :order => 'articles.created_at DESC', :conditions => 'article_id IS NULL', :include => :user
  end

  def create
    @article = current_user.articles.create params[:article].merge(:published_at => Time.now.utc)
  end

  def edit
    @tags    = Tag.find :all
    @article = Article.find(params[:id])
  end

  def update
    @article = Article.find(params[:id])
    if @article.update_attributes(params[:article])
      redirect_to :action => 'list'
    else
      @tags = Tag.find :all
      render :action => 'edit'
    end
  end

  protected
  def set_default_tag_ids
    params[:article][:tag_ids] ||= []
  end
end
