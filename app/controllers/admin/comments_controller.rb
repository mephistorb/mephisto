class Admin::CommentsController < Admin::BaseController

  member_actions.push(*%w(index unapproved create edit update approve unapprove destroy close ))

private

  before_filter :find_site_article, :except => [ :close, :index, :destroy ]
  before_filter :find_optional_site_article, :only => [:index, :destroy]
  def find_site_article
    @article = site.articles.find params[:article_id]
  end
  
  def find_optional_site_article
    @article = site.articles.find params[:article_id] unless params[:article_id].blank?
  end

  cache_sweeper :comment_sweeper, :only => [:approve, :unapprove, :destroy, :create]

public

  def index
    @comment  = Comment.new
    @articles = site.unapproved_comments.count :all, :group => :article, :order => '1 desc'
    params[:filter] = 'unapproved' if @article.nil?
    @comments = 
      (@article || @site).send case params[:filter]
        when 'approved'   then :comments
        when 'unapproved' then :unapproved_comments
        else                   :all_comments
      end
  end
  
  def unapproved
    site.unapproved_comments.find(:all, :include => :article)
  end
  
  def create
    @comment = @article.comments.build(params[:comment].merge(
      :user_id    => session[:user], 
      :author_ip  => request.remote_ip, 
      :user_agent => request.env['HTTP_USER_AGENT'], 
      :referrer   => request.env['HTTP_REFERER'])
    )
    @comment.approved = true
    @comment.save
  end
  
  def edit
    @comment = @article.all_comments.find params[:id]
  end
  
  def update
    @comment = @article.all_comments.find params[:id]
    @comment.update_attributes(params[:comment])
  end

  # xhr baby
  # needs some restful lovin'
  def approve
    @comment = @article.unapproved_comments.approve(params[:comment] || params[:id])
    @comment.mark_as_ham(site, request)
  end

  def unapprove
    @comment = @article.comments.unapprove(params[:comment] || params[:id])
    @comment.mark_as_spam(site, request)
    render :action => 'approve'
  end
  
  def destroy
    @comments = site.all_comments.find :all, :conditions => ['id in (?)', [ (params[:comment] || params[:id])].flatten] # rescue []
    Comment.transaction { @comments.each(&:destroy) } if @comments.any?
  end
  
  # ajax action, called from _page_nav
  def close
    @article = site.articles.find(params[:id])
    @article.update_attribute :comment_age, -1
    render :update do |page|
      page.flash.notice "Comments have been closed for this article"
    end
  end
end
