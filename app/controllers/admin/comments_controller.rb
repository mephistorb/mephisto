class Admin::CommentsController < Admin::BaseController
  def index
    @comments = site.unapproved_comments.find(:all, :include => :article)
  end
end
