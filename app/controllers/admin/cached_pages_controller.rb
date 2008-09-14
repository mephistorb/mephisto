class Admin::CachedPagesController < Admin::BaseController
  before_filter { |c| raise ActionController::UnknownController unless c.class.perform_caching }
  before_filter :protect_action, :only => :clear

  def index
    CachedPage.with_current_scope do
      @cached_pages = site.cached_pages.paginate(:order => 'updated_at',
                                                 :conditions => (params[:query] && ['url LIKE ?', ["#{params[:query]}%"]]),
                                                 :page => params[:page])
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
