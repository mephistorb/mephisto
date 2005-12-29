class ArticlesController < ApplicationController
  def index
    list
    render :action => 'list'
  end

  def list
    @tag = params[:tags].blank? ?
      Tag.find_by_name('home') :
      Tag.find_by_name(params[:tags].join('/'))

    @article_pages = Paginator.new self, @tag.articles.size, 15, params[:page]
    @articles = @tag.articles.find_by_date \
                          :limit  =>  @article_pages.items_per_page,
                          :offset =>  @article_pages.current.offset
  end

  def show
    @article = Article.find(params[:id])
  end

  def new
    @article = Article.new
  end

  def create
    @article = Article.new(params[:article])
    if @article.save
      flash[:notice] = 'Article was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @article = Article.find(params[:id])
  end

  def update
    @article = Article.find(params[:id])
    if @article.update_attributes(params[:article])
      flash[:notice] = 'Article was successfully updated.'
      redirect_to :action => 'show', :id => @article
    else
      render :action => 'edit'
    end
  end

  def destroy
    Article.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
end
