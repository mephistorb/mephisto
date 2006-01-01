class Admin::ArticlesController < Admin::BaseController
  def index
    @tags     = Tag.find :all
    @article  = Article.new
    @articles = Article.find :all, :order => 'created_at DESC', :conditions => 'article_id IS NULL'
  end

  def create
    tag_ids  = params[:article].delete('tag_ids')
    @article = Article.create params[:article]
    unless @article.new_record? or tag_ids.nil?
      tags = Tag.find(:all, :conditions => ['id in (?)', tag_ids])
      tags.each { |tag| @article.taggings.create :tag => tag }
    end
  end
end
