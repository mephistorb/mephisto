class MephistoController < ApplicationController
  session :off
  caches_page_with_references :list, :show, :date

  def list
    if params[:sections].blank?
      @section = site.sections.find_by_name('home')
      @section.show_paged_articles? ? show_section_page_with(nil, :main) : list_section_articles_with(:main)
    else 
      @section, page_name = site.sections.find_section_and_page_name(params[:sections].dup)
      @section ||= site.sections.find_by_name('home')
      if @section.show_paged_articles? 
        show_section_page_with(page_name, :page)
      else
        show_404 and return unless page_name.blank?
        list_section_articles_with(:section)
      end
    end
  end

  def search
    conditions     = ['published_at <= :now AND title LIKE :q OR excerpt LIKE :q OR body LIKE :q', 
                     { :now => Time.now.utc, :q => "%#{params[:q]}%" }]
    @article_pages = Paginator.new self, site.articles.count(conditions), site.articles_per_page, params[:page]
    @articles      = site.articles.find(:all, :conditions => conditions, :order => 'published_at DESC',
                       :include => [:user, :sections],
                       :limit   =>  @article_pages.items_per_page,
                       :offset  =>  @article_pages.current.offset)

    render_liquid_template_for(:search, 'articles'      => @articles,
                                        'previous_page' => paged_search_url_for(@article_pages.current.previous),
                                        'next_page'     => paged_search_url_for(@article_pages.current.next))
  end

  def show
    @article  = site.articles.find_by_permalink(params[:year], params[:month], params[:day], params[:permalink])
    show_404 and return unless @article
    @comments = @article.comments.collect { |c| c.to_liquid }
    self.cached_references << @article
    Mephisto::Liquid::CommentForm.article = @article
    @article  = @article.to_liquid(:single)
    render_liquid_template_for(:single, 'articles' => [@article], 'article' => @article, 'comments' => @comments)
  end

  def day
    @articles = site.articles.find_all_by_published_date(params[:year], params[:month], params[:day], :include => [:user, :sections])
    render_liquid_template_for(:archive, 'articles' => @articles)
  end

  def month
    count = site.articles.count_by_published_date(params[:year], params[:month], params[:day])
    @article_pages = Paginator.new self, count, site.articles_per_page, params[:page]
    @articles = site.articles.find_all_by_published_date(params[:year], params[:month], params[:day],
                  :include => [:user, :sections],
                  :limit   =>  @article_pages.items_per_page,
                  :offset  =>  @article_pages.current.offset)
    render_liquid_template_for(:archive, 'articles'      => @articles,
                                         'previous_page' => paged_monthly_url_for(@article_pages.current.previous),
                                         'next_page'     => paged_monthly_url_for(@article_pages.current.next))
  end

  protected
    def list_section_articles_with(template_type)
      @article_pages = Paginator.new self, @section.articles.size, @section.articles_per_page, params[:page]
      @articles      = @section.articles.find_by_date(
                         :include => [:user],
                         :limit   =>  @article_pages.items_per_page,
                         :offset  =>  @article_pages.current.offset)
    
      self.cached_references << @section
      render_liquid_template_for(template_type, 'section'       => @section.name, 
                                                'section_title' => @section.title,
                                                'articles'      => @articles,
                                                'previous_page' => paged_section_url_for(@article_pages.current.previous),
                                                'next_page'     => paged_section_url_for(@article_pages.current.next))
    end
    
    def show_section_page_with(page_name, template_type)
      @article = page_name.nil? ? @section.articles.find_by_position : @section.articles.find_by_permalink(page_name)
      show_404 and return unless @article
    
      self.cached_references << @section << @article
      Mephisto::Liquid::CommentForm.article = @article
      render_liquid_template_for(template_type, 'section'          => @section.name, 
                                                'section_title'    => @section.title,
                                                'pages'            => @section.articles.collect(&:to_liquid),
                                                'article'          => @article.to_liquid(:single),
                                                'article_sections' => @article.sections.collect(&:to_liquid))
    end
    
    def show_error(message = 'An error occurred.', status = '500 Error')
      render_liquid_template_for(:error, 'message' => message, :status => status)
    end

    def show_404
      show_error 'Page Not Found', '404 NotFound'
    end

    def paged_search_url_for(page)
      page ? search_url(:q => params[:q], :page => page) : ''
    end
    
    def paged_monthly_url_for(page)
      page ? paged_monthly_url(:year => params[:year], :month => params[:month], :page => page) : ''
    end
    
    def paged_section_url_for(page)
      page ? section_url(:sections => @section.to_url << 'page' << page) : ''
    end
end
