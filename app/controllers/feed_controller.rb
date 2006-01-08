class FeedController < ApplicationController
  layout nil
  session :off
  caches_page_with_references :feed

  def feed
    tags = params[:tags].clone
    last = tags.last
    tags.delete(last) if last =~ /\.xml$/
    
    @tag      = Tag.find_by_name(tags.blank? ? 'home' : tags.join('/'))
    @articles = @tag.articles.find_by_date(:limit => 15)
    self.cached_references += @articles
  end
end
