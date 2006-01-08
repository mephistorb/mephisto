class ArticleSweeper < ActionController::Caching::Sweeper
  observe Article

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