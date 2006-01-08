class MephistoController < ApplicationController
  session :off
  caches_page_with_references :list, :search, :show, :date

  def list
    if params[:tags].blank?
      @tag = Tag.find_by_name('home')
      template_type = :main
    else
      @tag = Tag.find_by_name(params[:tags].join('/'))
      template_type = :tag
    end

    @article_pages = Paginator.new self, @tag.articles.size, 15, params[:page]
    @articles      = @tag.articles.find_by_date(
                       :limit  =>  @article_pages.items_per_page,
                       :offset =>  @article_pages.current.offset)

    self.cached_references << @tag
    render_liquid_template_for(template_type, 'tag' => @tag.name, 'articles' => @articles)
  end

  def search
    conditions     = ['published_at <= :now AND type IS NULL AND title LIKE :q OR summary LIKE :q OR description LIKE :q', 
                     { :now => Time.now.utc, :q => "%#{params[:q]}%" }]
    @article_pages = Paginator.new self, Article.count(conditions), 15, params[:page]
    @articles      = Article.find(:all, :conditions => conditions, :order => 'published_at DESC',
                       :limit  =>  @article_pages.items_per_page,
                       :offset =>  @article_pages.current.offset)

    render_liquid_template_for(:search, 'tag' => @tag, 'articles' => @articles)
  end

  def show
    @article  = Article.find_by_permalink(params[:year], params[:month], params[:day], params[:permalink])
    @comments = @article.comments.collect { |c| c.to_liquid }
    self.cached_references << @article
    @article  = @article.to_liquid(:single)
    render_liquid_template_for(:single, 'articles' => [@article], 'article' => @article, 'comments' => @comments)
  end

  def date
    @articles = Article.find_all_by_published_date(params[:year], params[:month], params[:day])
    render_liquid_template_for(:archive, 'articles' => @articles)
  end

  protected
  def render_liquid_template_for(template_type, assigns = {})
    headers["Content-Type"] ||= 'text/html; charset=utf-8'
    templates                 = Template.templates_for(template_type)
    preferred_template        = Template.find_preferred(template_type, templates)
    layout_template           = templates['layout']
    unless assigns['article']
      self.cached_references += assigns['articles']
      assigns['articles']     = assigns['articles'].collect { |a| a.to_liquid }
    end
    assigns.merge! 'content_for_layout' => Liquid::Template.parse(preferred_template).render(assigns)
    render :text => Liquid::Template.parse(layout_template).render(assigns)
  end
end
