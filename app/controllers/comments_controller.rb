class CommentsController < ApplicationController
  cache_sweeper :comment_sweeper
  verify :params => [:year, :month, :day, :permalink], :redirect_to => { :controller => 'mephisto', :action => 'list', :sections => [] }
  observer :article_observer

  def create
    @article  = Article.find_by_permalink(params[:year], params[:month], params[:day], params[:permalink])
    
    redirect_to(section_url(:sections => [])) and return unless @article
    if request.get? or params[:comment].blank?
      redirect_to(article_url(@article.hash_for_permalink)) and return
    end

    @comment = @article.comments.create(params[:comment].merge(:author_ip => request.remote_ip))
    if @comment.new_record?
      @comments = @article.comments.select { |c| not c.new_record? }.collect { |c| c.to_liquid }
      @article  = @article.to_liquid(:single)
      render_liquid_template_for(:single, 'articles' => [@article], 
                                          'article'  => @article, 
                                          'comments' => @comments, 
                                          'errors'   => @comment.errors.full_messages)
    else
      redirect_to article_url(@article.hash_for_permalink(:anchor => "comment_#{@comment.id}"))
    end
  end
end
