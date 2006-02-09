class FeedController < ApplicationController
  layout nil
  session :off
  caches_page_with_references :feed

  def feed
    categories = params[:categories].clone
    last = categories.last
    categories.delete(last) if last =~ /\.xml$/
    
    @category      = Category.find_by_name(categories.blank? ? 'home' : categories.join('/'))
    @articles = @category.articles.find_by_date(:limit => 15)
    self.cached_references += @articles
  end
end
