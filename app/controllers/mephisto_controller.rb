class MephistoController < ApplicationController
  layout 'default'
  session :off

  def list
    if params[:tags].blank?
      @tag = Tag.find_by_name('home')
      template_type = :main
    else
      @tag = Tag.find_by_name(params[:tags].join('/'))
      template_type = :tag
    end

    @article_pages = Paginator.new self, @tag.articles.size, 15, params[:page]
    @articles = @tag.articles.find_by_date(
                  :limit  =>  @article_pages.items_per_page,
                  :offset =>  @article_pages.current.offset).collect { |a| a.to_liquid }

    render_liquid_template_for(template_type, 'tag' => @tag, 'articles' => @articles)
  end

  def search
    conditions = ['title LIKE :q OR summary LIKE :q OR description LIKE :q', { :q => "%#{params[:q]}%" }]
    @article_pages = Paginator.new self, Article.count(conditions), 15, params[:page]
    @articles = Article.find(:all, :conditions => conditions, :order => 'published_at DESC',
                  :limit  =>  @article_pages.items_per_page,
                  :offset =>  @article_pages.current.offset).collect { |a| a.to_liquid }

    render_liquid_template_for(:search, 'tag' => @tag, 'articles' => @articles)
  end

  def show
    @article = Article.find_by_permalink(params[:year], params[:month], params[:day], params[:permalink])
    @comments = @article.comments.collect { |c| c.to_liquid }
    render_liquid_template_for(:single, 'articles' => [@article.to_liquid], 'comments' => @comments)
  end

  protected
  def render_liquid_template_for(template_type, assigns = {})
    headers["Content-Type"] ||= 'text/html; charset=utf-8'
    templates          = Template.templates_for(template_type)
    preferred_template = Template.find_preferred(template_type, templates)
    layout_template    = templates['layout']
    assigns.merge! 'content_for_layout' => Liquid::Template.parse(preferred_template).render(assigns)
    render :text => Liquid::Template.parse(layout_template).render(assigns)
  end
end
