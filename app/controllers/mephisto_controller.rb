class MephistoController < ApplicationController
  layout nil
  session :off
  caches_page_with_references :dispatch
  cache_sweeper :comment_sweeper

  def dispatch
    @dispatch_path    = Mephisto::Dispatcher.run(site, params[:path].dup)
    @dispatch_action  = @dispatch_path.shift
    @section          = @dispatch_path.shift
    @dispatch_action == :error ? show_404 : send("dispatch_#{@dispatch_action}")
  end

  protected
    def dispatch_redirect
      @skip_caching = true
      # @section is the http status
      # @dispatch_path.first has the headers
      if @dispatch_path.first.is_a?(Hash)
        response.headers['Status'] = interpret_status @section
        redirect_to @dispatch_path.first[:location], :status=>301
      else
        head @section
      end
    end

    def dispatch_list
      @articles = @section.articles.find_by_date(:include => :user, :limit => @section.articles_per_page)
      render_liquid_template_for(@section.show_paged_articles? ? :page : :section, 
        'section'  => @section.to_liquid(true), 'articles' => @articles)
    end

    def dispatch_page
      Article.with_published do
        @article = @dispatch_path.empty? ? @section.articles.find_by_position : @section.articles.find_by_permalink(@dispatch_path.first)
      end
      show_404 and return unless @article
      Mephisto::Liquid::CommentForm.article = @article
      render_liquid_template_for(:page, 'section' => @section.to_liquid(true),
                                        'article' => @article.to_liquid(:mode => :single, :page => @dispatch_path.empty?))
    end
    
    def dispatch_comments
      @skip_caching = true
      show_404 and return unless find_article
      if !request.post? || params[:comment].blank?
        redirect_to site.permalink_for(@article) and return
      end

      # Since this input is utterly untrustworthy (no authenticity_token,
      # session, or anything else required), build the record manually.
      comment_data = {
        :user_id => session[:user],
        :author_ip => request.remote_ip,
        :user_agent => request.user_agent,
        :referrer => request.referer,
        :author => params[:comment][:author],
        :author_email => params[:comment][:author_email],
        :author_url => params[:comment][:author_url],
        :body => params[:comment][:body]
      }
      @comment = @article.comments.build(comment_data)
      @comment.check_approval site, request if @comment.valid?
      @comment.save!
      redirect_to dispatch_path(:path => (site.permalink_for(@article)[1..-1].split('/') << 'comments' << @comment.id.to_s), :anchor => @comment.dom_id)
    rescue ActiveRecord::RecordInvalid
      show_article_with 'errors' => @comment.errors.full_messages, 'submitted' => params[:comment]
    rescue Article::CommentNotAllowed
      commenting_disabled = site.call_render(nil, :__commenting_disabled, {}, nil, :layout => false) rescue "Commenting has been disabled on this article"
      @article.reload
      show_article_with 'errors' => [commenting_disabled]
    rescue Comment::Previewing
      previewing_comment = site.call_render(nil, :__previewing_comment, {}, nil, :layout => false) rescue "Previewing your comment"
      show_article_with 'errors' => [previewing_comment], 'submitted' => params[:comment]
    end
    
    def dispatch_comment
      @skip_caching = true
      message = site.call_render(nil, :__thanks_for_comment, {}, nil, :layout => false) rescue "Thanks for the comment!"
      show_article_with 'message' => message
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
      render_liquid_template_for(:archive, 'section' => @section, 'articles' => @articles, 'archive_date' => Time.utc(year, month))
    end

    def dispatch_search
      @section = params[:s].nil? ? nil : site.sections.detect { |s| s.path == params[:s] }
      joins          = nil
      conditions     = ['(published_at IS NOT NULL AND published_at <= :now) AND (title LIKE :q OR excerpt LIKE :q OR body LIKE :q)', 
                       { :now => Time.now.utc, :q => "%#{params[:q]}%" }]
      if @section
        conditions.first << ' AND (assigned_sections.section_id = :section)'
        conditions.last[:section] = @section.id
      end

      @articles = site.articles.paginate(:conditions => conditions, :order => 'published_at DESC',
                                         :include => [:user, :sections],
                                         :per_page => site.articles_per_page, :page => params[:page])
      
      render_liquid_template_for(:search, 'articles'      => @articles,
                                          'previous_page' => paged_search_url_for(@articles.previous_page),
                                          'next_page'     => paged_search_url_for(@articles.next_page),
                                          'search_string' => CGI::escapeHTML(params[:q]),
                                          'search_count'  => @articles.total_entries,
                                          'section'       => @section)
      @skip_caching = true
    end
    
    def dispatch_tags
      @articles = site.articles.find_all_by_tags(@dispatch_path, site.articles_per_page)
      render_liquid_template_for(:tag, 'articles' => @articles, 'tags' => @dispatch_path)
    end

    def dispatch_comments_feed
      show_404 and return unless find_article
      @feed_title = "Comments"
      @comments = @article.comments
      @comments.reverse!
      respond_to do |format|
        format.xml do
          render :action => 'feed', :content_type => 'application/xml'
        end
      end
    end

    def dispatch_changes_feed
      show_404 and return unless find_article
      @feed_title = "Changes"
      @articles = @article.versions.find(:all, :include => :updater, :order => 'version desc')
      respond_to do |format|
        format.xml do
          render :action => 'feed', :content_type => 'application/xml'
        end
      end
    end

    def paged_search_url_for(page)
      page ? site.search_url(params[:q], page) : ''
    end

    def find_article
      cached_references << (@article = site.articles.find_by_permalink(@dispatch_path.first))
      @article
    end

    def show_article_with(assigns = {})
      find_article if @article.nil?
      show_404 and return unless @article || find_article
      Mephisto::Liquid::CommentForm.article = @article
      @article = @article.to_liquid(:mode => :single)
      render_liquid_template_for(:single, assigns.update('articles' => [@article], 'article' => @article))
    end
    alias dispatch_single show_article_with
end
