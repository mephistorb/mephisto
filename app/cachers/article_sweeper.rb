class ArticleSweeper < ActionController::Caching::Sweeper
  observe Article

  def after_create(record)
    controller.expire_page :categories => [], :controller => '/mephisto', :action => 'list'
    controller.expire_page :categories => [], :controller => '/feed', :action => 'feed'
    Category.find(:all, :conditions => ['name != ?', 'home']).each do |category|
      controller.expire_page :categories => category.name.split('/'), :controller => '/mephisto', :action => 'list'
      controller.expire_page :categories => category.name.split('/'), :controller => '/feed', :action => 'feed'
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

  alias_method :after_destroy, :after_save
end