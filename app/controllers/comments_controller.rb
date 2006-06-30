class CommentsController < ApplicationController
  cache_sweeper :comment_sweeper
  verify :params => [:year, :month, :day, :permalink], :redirect_to => { :controller => 'mephisto', :action => 'list', :sections => [] }
  before_filter :find_article

  def show
    show_article_with 'message' => 'Thank you for comment.  Your comment requires approval from the blog author before showing up.'
  end

  def create
    @article  = site.articles.find_by_permalink(params[:year], params[:month], params[:day], params[:permalink])
    
    redirect_to(section_url(:sections => [])) and return unless @article
    if request.get? || params[:comment].blank?
      redirect_to(article_url(@article.hash_for_permalink)) and return
    end

    @comment = @article.comments.build(params[:comment].merge(:author_ip => request.remote_ip))
    if @comment.valid? && Akismet.api_key && Akismet.blog
      @comment.approved = Akismet.new(Akismet.api_key, Akismet.blog).comment_check \
        :user_ip              => @comment.author_ip, 
        :user_agent           => request.user_agent, 
        :referrer             => request.referer,
        :permalink            => article_url(@article.hash_for_permalink), 
        :comment_author       => @comment.author, 
        :comment_author_email => @comment.author_email, 
        :comment_author_url   => @comment.author_url, 
        :comment_content      => @comment.body
      logger.info "Checking Akismet (#{Akismet.api_key}) for new comment on Article #{@article.id}.  #{@comment.approved ? 'Approved' : 'Blocked'}"
    end

    @comment.save!
    redirect_to comment_preview_url(@article.hash_for_permalink(:comment => @comment))
  rescue ActiveRecord::RecordInvalid
    show_article_with 'errors' => @comment.errors.full_messages
  rescue Article::CommentNotAllowed
    show_article_with 'errors' => ["Commenting has been disabled on this article"]
  end
  
  protected
    def find_article
      @article = site.articles.find_by_permalink(params[:year], params[:month], params[:day], params[:permalink])
    end

    def show_article_with(assigns)
      Mephisto::Liquid::CommentForm.article = @article
      @comments = @article.comments.reject(&:new_record?).collect(&:to_liquid)
      @article  = @article.to_liquid(:single)
      render_liquid_template_for(:single, assigns.merge('articles' => [@article], 
                                          'article'  => @article, 
                                          'comments' => @comments))
    end
end
