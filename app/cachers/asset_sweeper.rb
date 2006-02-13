class AssetSweeper < ActionController::Caching::Sweeper
  observe Resource
  def after_save(record)
    pages = CachedPage.find_by_reference(record)
    if pages.any?
      controller.class.benchmark "Expired pages referenced by #{record.class} ##{record.id}" do
        pages.each { |p| controller.class.expire_page(p.url) }
        CachedPage.expire_pages(pages)
      end
    end
  end
  alias after_destroy after_save
end