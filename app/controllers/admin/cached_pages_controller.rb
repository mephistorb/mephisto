class Admin::CachedPagesController < Admin::BaseController
  before_filter { |c| raise ActionController::UnknownController unless c.class.perform_caching }

  def index
    CachedPage.with_current_scope do
      @cached_page_pages, @cached_pages = paginate :cached_pages, :order => 'updated_at', :per_page => 30, 
        :conditions => (params[:query] && ['url LIKE ?', ["#{params[:query]}%"]])
    end
  end
  alias_method :query, :index

  def destroy
    page = site.cached_pages.find params[:id]
    self.class.expire_page page.url
  end
  
  def clear
    site.cached_pages.each { |p| self.class.expire_page(p.url) }
    query
  end
  
  protected
    alias authorized? admin?
end