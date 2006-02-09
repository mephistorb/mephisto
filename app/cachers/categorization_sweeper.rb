class CategorizationSweeper < ActionController::Caching::Sweeper
  observe Categorization

  def after_destroy(record)
    pages = CachedPage.find_by_reference_key('Category', record.category_id)
    unless pages.empty?
      controller.class.benchmark "Expired pages referenced by Category ##{record.category_id}" do
        pages.each { |p| controller.class.expire_page(p.url) }
        CachedPage.expire_pages(pages)
      end
    end
  end
end