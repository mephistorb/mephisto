class Admin::ArticlesController < Admin::BaseController
  with_options :only => [:create, :update] do |c|
    c.before_filter :set_default_category_ids
    c.before_filter :clear_published_at_fields!
    c.cache_sweeper :article_sweeper
    c.cache_sweeper :Category_sweeper
  end

  before_filter :load_categories, :only => [:new, :edit]

  def index
    conditions     = 'article_id IS NULL'
    @article_pages = Paginator.new self, Article.count(conditions), 30, params[:page]
    @articles      = Article.find(:all, :conditions => conditions, :order => 'articles.created_at DESC',
                       :include => :user,
                       :limit   =>  @article_pages.items_per_page,
                       :offset  =>  @article_pages.current.offset)
  end
  
  def new
    @article = Article.new
  end

  def create
    @article = current_user.articles.create params[:article]
    if @article.new_record?
      load_categories and render :action => 'new'
    else
      redirect_to :action => 'index'
    end
  end

  def edit
    @article = Article.find(params[:id])
  end

  def update
    @article = Article.find(params[:id])
    if @article.update_attributes(params[:article])
      redirect_to :action => 'index'
    else
      @categories = Category.find :all
      render :action => 'edit'
    end
  end
  
  def live_preview
    @article = Article.new params[:article]
  end
  
  protected
  def load_categories
    @categories = Category.find :all, :order => 'name'
  end

  def set_default_category_ids
    params[:article][:category_ids] ||= []
  end

  def clear_published_at_fields!
    return if params[:article_published]
    params[:article].keys.select { |k| k =~ /^published_at/ }.each { |k| params[:article].delete(k) }
    params[:article][:published_at] = nil
  end
end
