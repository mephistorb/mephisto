class FeedController < ApplicationController
  layout nil
  session :off
  caches_page_with_references :feed

  def feed
    sections = params[:sections].clone
    last = sections.last
    sections.delete(last) if last =~ /\.xml\z/
    @section_path = sections.blank? ? '' : sections.join('/')
    case last
    when 'all_comments.xml'
      comment_feed_for_site
    when 'comments.xml'
      comment_feed_for_section
    else
      article_feed_for_section
    end

    respond_to do |format|
      format.xml
    end
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  protected
    def article_feed_for_section
      @section  = site.sections.find_by_path(@section_path) || raise(ActiveRecord::RecordNotFound)
      @articles = @section.articles.find_by_date(:limit => 15, :include => :user)
      cached_references      << @section
      self.cached_references += @articles
    end
    
    def comment_feed_for_section
      @section  = site.sections.find_by_path(@section_path) || raise(ActiveRecord::RecordNotFound)
      @comments = @section.find_comments(:limit => 15, :include => :article)
      cached_references      << @section
      self.cached_references += @comments
      self.cached_references += @comments.collect(&:article_referenced_cache_key)
    end
    
    def comment_feed_for_site
      @comments = site.comments.find(:all, :limit => 15, :include => :article)
      self.cached_references += @comments
      self.cached_references += @comments.collect(&:article_referenced_cache_key)
    end
end
