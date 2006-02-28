class ArticleSweeper < ActionController::Caching::Sweeper
  observe Article

  def after_create(record)
    return if controller.nil?
    record.send :save_assigned_sections
    record.sections.each do |section|
      controller.expire_page :sections => section.to_url,      :controller => '/mephisto', :action => 'list'
      controller.expire_page :sections => section.to_feed_url, :controller => '/feed',     :action => 'feed'
    end
  end

  def after_save(record)
    return if controller.nil?
    pages = CachedPage.find_by_reference(record)
    controller.class.benchmark "Expired pages referenced by #{record.class} ##{record.id}" do
      pages.each { |p| controller.class.expire_page(p.url) }
      CachedPage.expire_pages(pages)
    end if pages.any?
  end

  alias after_destroy after_save
end