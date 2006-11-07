class Admin::CommentsController < Admin::BaseController
  def index
    @comments = site.unapproved_comments.find(:all, :include => :article)
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
