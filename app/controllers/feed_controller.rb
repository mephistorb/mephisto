class FeedController < ApplicationController
  layout nil
  session :off
  caches_page_with_references :feed

  def feed
    sections = params[:sections].clone
    last = sections.last
    sections.delete(last) if last =~ /\.xml$/
    
    @section  = site.sections.find_by_name(sections.blank? ? 'home' : sections.join('/'))
    @articles = @section.articles.find_by_date(:limit => 15)
    self.cached_references += @articles
  end
end
