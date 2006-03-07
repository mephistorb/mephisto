class Admin::ArticlesController < Admin::BaseController
  with_options :only => [:create, :update] do |c|
    c.before_filter :set_default_section_ids
    c.before_filter :clear_published_at_fields!
    c.before_filter :save_or_draft
    c.cache_sweeper :article_sweeper
    c.cache_sweeper :section_sweeper
  end

  before_filter :load_sections, :only => [:new, :edit, :draft]

  def index
    @drafts        = Article::Draft.find_new
    @article_pages = Paginator.new self, Article.count, 30, params[:page]
    @articles      = Article.find(:all, :order => 'contents.created_at DESC',
                       :include => [:user, :draft],
                       :limit   =>  @article_pages.items_per_page,
                       :offset  =>  @article_pages.current.offset)
  end

  def show
    @article  = Article.find_by_id(params[:id], :include => :comments)
    @comments = @article.comments.collect { |c| c.to_liquid }
    @article  = @article.to_liquid(:single)
    render :text => Template.render_liquid_for(:single, 'articles' => [@article], 'article' => @article, 'comments' => @comments, 'site' => current_site.to_liquid)
  end

  def new
    @article = Article.new
  end

  def edit
    @article = Article.find(params[:id], :include => :draft)
    @version = params[:version] ? @article.find_version(params[:version]) : @article
  end

  def create
    @article = current_user.articles.create params[:article].merge(:updater => current_user)
    if @article.new_record?
      load_sections
      render :action => 'new'
    else
      redirect_to :action => 'index'
    end
  end
  
  def update
    @article = Article.find(params[:id])
    if @article.update_attributes(params[:article].merge(:updater => current_user))
      redirect_to :action => 'index'
    else
      @sections = Section.find :all
      render :action => 'edit'
    end
  end

  def draft
    @draft   = Article::Draft.find(params[:id], :include => :article)
    @article = @draft.to_article
    render :action => (@article.new_record? ? :new : :edit)
  end

  protected
  def save_or_draft
    if draft?(params[:submit])
      params[:id] ? update_draft : create_draft
      @article.save_draft
      @draft = @article.draft
      flash[:notice] = "Your draft has been created"
      redirect_to :action => 'index'
      return false
    end
  end

  def update_draft
    @article = Article.find(params[:id])
    @article.attributes = params[:article]
  end

  def create_draft
    @article = Article.new(params[:article])
  end

  def load_sections
    @sections = Section.find :all, :order => 'name'
    home = @sections.find { |s| s.name == 'home' }
    @sections.delete  home
    @sections.unshift home
  end

  def set_default_section_ids
    params[:article][:section_ids] ||= []
  end

  def clear_published_at_fields!
    return if params[:article_published]
    params[:article].keys.select { |k| k =~ /^published_at/ }.each { |k| params[:article].delete(k) }
    params[:article][:published_at] = nil
    true
  end

  def save_button
    @save_button ||= 'Apply Changes'
  end

  def create_button
    @create_button ||= 'Save Article'
  end

  def draft_button
    @draft_button ||= 'Save as Draft'
  end

  def draft?(value)
    (@draft_options ||= [draft_button, :draft]).include? value
  end

  helper_method :save_button, :create_button, :draft_button
end
