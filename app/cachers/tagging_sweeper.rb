class TaggingSweeper < ActionController::Caching::Sweeper
  observe Tagging

  def after_destroy(record)
    pages = CachedPage.find_by_reference_key('Tag', record.tag_id)
    unless pages.empty?
      controller.class.benchmark "Expired pages referenced by Tag ##{record.tag_id}" do
        pages.each { |p| controller.class.expire_page(p.url) }
        CachedPage.expire_pages(pages)
      end
    end
  end
end