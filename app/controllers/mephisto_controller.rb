class MephistoController < ApplicationController
  session :off
  caches_page_with_references :dispatch
  cache_sweeper :comment_sweeper
  observer      :comment_observer

  def dispatch
    @dispatch_path    = Mephisto::Dispatcher.run(site, params[:path].dup)
    @dispatch_action  = @dispatch_path.shift
    @section          = @dispatch_path.shift
    @dispatch_action == :error ? show_404 : send("dispatch_#{@dispatch_action}")
  end

  protected
    def dispatch_list
      @articles = @section.articles.find_by_date(:include => :user)
      self.cached_references << @section
      render_liquid_template_for(:section, 'section'  => @section.to_liquid(true),
                                           'articles' => @articles)
    end

    def dispatch_page
      @article = @dispatch_path.empty? ? @section.articles.find_by_position : @section.articles.find_by_permalink(@dispatch_path.first)
      show_404 and return unless @article
    
      self.cached_references << @section << @article
      Mephisto::Liquid::CommentForm.article = @article
      articles = []
      @section.articles.each_with_index do |article, i|
        articles << article.to_liquid(:page => i.zero?)
      end
      render_liquid_template_for(:page, 'section' => @section.to_liquid(true),
                                        'pages'   => articles,
                                        'article' => @article.to_liquid(:mode => :single, :site => site))
    end

    def dispatch_single
      show_article
    end
    
    def dispatch_comments
      show_404 and return unless find_article
      if request.get? || params[:comment].blank?
        redirect_to site.permalink_for(@article) and return
      end
    
      @comment = @article.comments.build(params[:comment].merge(:author_ip => request.remote_ip))
    
      if @comment.valid?
        @comment.approved = site.approve_comments?
        if [:akismet_key, :akismet_url].all? { |attr| !site.send(attr).blank? }
          @comment.approved = Akismet.new(site.akismet_key, site.akismet_url).comment_check \
            :user_ip              => @comment.author_ip, 
            :user_agent           => request.user_agent, 
            :referrer             => request.referer,
            :permalink            => "http://#{request.host_with_port}#{site.permalink_for(@article)}", 
            :comment_author       => @comment.author, 
            :comment_author_email => @comment.author_email, 
            :comment_author_url   => @comment.author_url, 
            :comment_content      => @comment.body
          logger.info "Checking Akismet (#{site.akismet_key}) for new comment on Article #{@article.id}.  #{@comment.approved ? 'Approved' : 'Blocked'}"
        end
      end
    
      @comment.save!
      redirect_to dispatch_path(:path => (site.permalink_for(@article)[1..-1].split('/') << 'comments' << @comment.id.to_s), :anchor => @comment.dom_id)
    rescue ActiveRecord::RecordInvalid
      show_article_with 'errors' => @comment.errors.full_messages, 'submitted' => params[:comment]
    rescue Article::CommentNotAllowed
      show_article_with 'errors' => ["Commenting has been disabled on this article"]
    end
    
    def dispatch_comment
      show_article_with 'message' => 'Thanks for the comment!'
    end

    def dispatch_archives
      year  = @dispatch_path.shift
      month = @dispatch_path.shift
      if year
        month ||= '1'
      else
        year  = Time.now.utc.year
        month = Time.now.utc.month
      end
      @articles = @section.articles.find_all_in_month(year, month, :include => :user)
      render_liquid_template_for(:archive, 'articles' => @articles, 'archive_date' => Time.utc(year, month))
    end

    def dispatch_search
      conditions     = ['(published_at IS NOT NULL AND published_at <= :now) AND (title LIKE :q OR excerpt LIKE :q OR body LIKE :q)', 
                       { :now => Time.now.utc, :q => "%#{params[:q]}%" }]
      search_count   = site.articles.count(conditions)
      @article_pages = Paginator.new self, search_count, site.articles_per_page, params[:page]
      @articles      = site.articles.find(:all, :conditions => conditions, :order => 'published_at DESC',
                         :include => [:user, :sections],
                         :limit   =>  @article_pages.items_per_page,
                         :offset  =>  @article_pages.current.offset)
      
      render_liquid_template_for(:search, 'articles'      => @articles,
                                          'previous_page' => paged_search_url_for(@article_pages.current.previous),
                                          'next_page'     => paged_search_url_for(@article_pages.current.next),
                                          'search_string' => params[:q],
                                          'search_count'  => search_count)
    end
    
    def dispatch_tags
      @articles = site.articles.find_all_by_tags(@dispatch_path)
      self.cached_references << @section
      render_liquid_template_for(:archive, 'articles' => @articles)
    end

    def paged_search_url_for(page)
      page ? search_url(:q => params[:q], :page => page) : ''
    end

    def find_article
      @article = site.articles.find_by_permalink(@dispatch_path.first)
    end

    def show_article_with(assigns = {})
      find_article if @article.nil?
      show_404 and return unless @article
      @comments = @article.comments.reject(&:new_record?).collect(&:to_liquid)
      self.cached_references << @article
      Mephisto::Liquid::CommentForm.article = @article
      @article  = @article.to_liquid(:mode => :single, :site => site)
      render_liquid_template_for(:single, assigns.merge('articles' => [@article], 'article' => @article, 'comments' => @comments))
    end

    alias show_article show_article_with
end
