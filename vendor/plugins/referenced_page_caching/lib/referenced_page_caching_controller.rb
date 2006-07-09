class ReferencedPageCachingController < ActionController::Base
  cattr_accessor :enabled
  layout nil
  
  before_filter { |c| c.render(:text => 'Referenced Page Caching is disabled', :status => '500 Error') unless c.enabled }

  def index
    @cached_page_pages, @cached_pages = paginate :cached_pages, :order => 'updated_at', :per_page => 30, 
      :conditions => (params[:query] && ['url LIKE ?', ["%#{params[:query]}%"]])
  end
  
  alias_method :query, :index

  def destroy
    page = CachedPage.find params[:id]
    self.class.expire_page page.url
    page.destroy
  end
  
  def clear
    CachedPage.find(:all).each { |p| self.class.expire_page(p.url) }
    CachedPage.delete_all
    query
  end
end