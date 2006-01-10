class CommentsController < ApplicationController
  def create
    @article  = Article.find_by_permalink(params[:year], params[:month], params[:day], params[:permalink])
    @comment  = @article.comments.create(params[:comment].merge(:author_ip => request.remote_ip))
    if @comment.new_record?
      @comments = @article.comments.collect { |c| c.to_liquid }
      @article  = @article.to_liquid(:single)
      render_liquid_template_for(:single, 'articles' => [@article], 'article' => @article, 'comments' => @comments)
    else
      redirect_to article_url(@article.hash_for_permalink(:anchor => "comment_#{@comment.id}"))
    end
  end
end
