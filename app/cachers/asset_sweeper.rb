class AssetSweeper < ActionController::Caching::Sweeper
  observe Resource
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