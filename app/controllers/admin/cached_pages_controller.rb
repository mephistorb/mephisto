class Admin::CachedPagesController < Admin::BaseController
  before_filter { |c| raise ActionController::UnknownController unless c.class.perform_caching }

  def index
    CachedPage.with_current_scope do
      @cached_page_pages = Paginator.new self, site.cached_pages.count, 30, params[:page]
      offset = (((params[:page] || 1).to_i - 1) * @cached_page_pages.items_per_page)
      @cached_pages = site.cached_pages.find(:all, :order => 'updated_at', :limit => @cached_page_pages.items_per_page, :offset => offset,
        :conditions => (params[:query] && ['url LIKE ?', ["#{params[:query]}%"]]))
    end
  end
  alias_method :query, :index

  def destroy
    page = site.cached_pages.find params[:id]
    page.update_attribute :cleared_at, Time.now.utc
    self.class.expire_page page.url
  end
  
  def clear
    site.cached_pages.each { |p| self.class.expire_page(p.url) }
    CachedPage.expire_pages site, site.cached_pages
    query
  end
  
  protected
    alias authorized? admin?
end