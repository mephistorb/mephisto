class AssignedSectionSweeper < ActionController::Caching::Sweeper
  observe AssignedSection

  def after_destroy(record)
    return if controller.nil?
    pages = CachedPage.find_by_reference_key('Section', record.section_id)
    controller.class.benchmark "Expired pages referenced by Section ##{record.section_id}" do
      pages.each { |p| controller.class.expire_page(p.url) }
      CachedPage.expire_pages(pages)
    end if pages.any?
  end
end