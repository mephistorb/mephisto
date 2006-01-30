class ArticleSweeper < ActionController::Caching::Sweeper
  observe Article

  def after_create(record)
    controller.expire_page :tags => [], :controller => '/mephisto', :action => 'list'
    controller.expire_page :tags => [], :controller => '/feed', :action => 'feed'
    Tag.find(:all, :conditions => ['name != ?', 'home']).each do |tag|
      controller.expire_page :tags => tag.name.split('/'), :controller => '/mephisto', :action => 'list'
      controller.expire_page :tags => tag.name.split('/'), :controller => '/feed', :action => 'feed'
    end
  end

  def after_save(record)
    pages = CachedPage.find_by_reference(record)
    unless pages.empty?
      controller.class.benchmark "Expired pages referenced by #{record.class} ##{record.id}" do
        pages.each { |p| controller.class.expire_page(p.url) }
        CachedPage.expire_pages(pages)
      end
    end
  end
end