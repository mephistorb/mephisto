class MephistoController < ApplicationController
  session :off
  caches_page_with_references :list, :search, :show, :date

  def list
    if params[:tags].blank?
      @tag = Tag.find_by_name('home')
      list_tag_articles_with(:main)
    else
      @tag, page_name = Tag.find_tag_and_page_name(params[:tags])
      @tag.show_paged_articles? ? show_tag_page_with(page_name, :page) : list_tag_articles_with(:tag)
    end
  end

  def search
    conditions     = ['published_at <= :now AND type IS NULL AND title LIKE :q OR summary LIKE :q OR description LIKE :q', 
                     { :now => Time.now.utc, :q => "%#{params[:q]}%" }]
    @article_pages = Paginator.new self, Article.count(conditions), 15, params[:page]
    @articles      = Article.find(:all, :conditions => conditions, :order => 'published_at DESC',
                       :limit  =>  @article_pages.items_per_page,
                       :offset =>  @article_pages.current.offset)

    render_liquid_template_for(:search, 'tag' => @tag, 'articles' => @articles,
                                        'previous_page' => paged_search_url_for(@article_pages.current.previous),
                                        'next_page'     => paged_search_url_for(@article_pages.current.next))
  end

  def show
    @article  = Article.find_by_permalink(params[:year], params[:month], params[:day], params[:permalink])
    @comments = @article.comments.collect { |c| c.to_liquid }
    self.cached_references << @article
    @article  = @article.to_liquid(:single)
    render_liquid_template_for(:single, 'articles' => [@article], 'article' => @article, 'comments' => @comments)
  end

  def day
    @articles = Article.find_all_by_published_date(params[:year], params[:month], params[:day])
    render_liquid_template_for(:archive, 'articles' => @articles)
  end

  def month
    count = Article.count_by_published_date(params[:year], params[:month], params[:day])
    @article_pages = Paginator.new self, count, 15, params[:page]
    @articles = Article.find_all_by_published_date(params[:year], params[:month], params[:day],
                  :limit  =>  @article_pages.items_per_page,
                  :offset =>  @article_pages.current.offset)
    render_liquid_template_for(:archive, 'articles'      => @articles,
                                         'previous_page' => paged_monthly_url_for(@article_pages.current.previous),
                                         'next_page'     => paged_monthly_url_for(@article_pages.current.next))
  end

  protected
  def list_tag_articles_with(template_type)
    @article_pages = Paginator.new self, @tag.articles.size, 15, params[:page]
    @articles      = @tag.articles.find_by_date(
                       :limit  =>  @article_pages.items_per_page,
                       :offset =>  @article_pages.current.offset)

    self.cached_references << @tag
    render_liquid_template_for(template_type, 'tag'           => @tag.name, 
                                              'articles'      => @articles,
                                              'previous_page' => paged_tags_url_for(@article_pages.current.previous),
                                              'next_page'     => paged_tags_url_for(@article_pages.current.next))
  end

  def show_tag_page_with(page_name, template_type)
    @article = page_name.nil? ? @tag.articles.find_by_position : @tag.articles.find_by_permalink(page_name)

    self.cached_references << @tag << @article
    render_liquid_template_for(template_type, 'tag'     => @tag.name, 
                                              'pages'   => @tag.articles.collect { |a| a.to_liquid },
                                              'article' => @article.to_liquid(:single))
  end

  def paged_search_url_for(page)
    page ? paged_search_url(:q => params[:q], :page => page) : ''
  end

  def paged_monthly_url_for(page)
    page ? paged_monthly_url(:year => params[:year], :month => params[:month], :page => page) : ''
  end

  def paged_tags_url_for(page)
    page ? tags_url(:tags => @tag.to_url << 'page' << page) : ''
  end
end
