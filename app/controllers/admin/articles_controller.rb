class Admin::ArticlesController < Admin::BaseController
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
      render :action => 'edit'
    end
  end
end
