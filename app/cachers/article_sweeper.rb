class ArticleSweeper < ActionController::Caching::Sweeper
  observe Article

  def after_create(record)
    Section.find(:all).collect { |section| section.to_url }.each do |section|
      controller.expire_page :sections => section, :controller => '/mephisto', :action => 'list'
      controller.expire_page :sections => section, :controller => '/feed',     :action => 'feed'
    end
  end

  def after_save(record)
    pages = CachedPage.find_by_reference(record)
    if pages.any?
      controller.class.benchmark "Expired pages referenced by #{record.class} ##{record.id}" do
        pages.each { |p| controller.class.expire_page(p.url) }
        CachedPage.expire_pages(pages)
      end
    end
  end

  alias_method :after_destroy, :after_save
end