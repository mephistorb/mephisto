class AssignedSectionSweeper < ActionController::Caching::Sweeper
  include Mephisto::SweeperMethods
  observe AssignedSection

  def after_destroy(record)
    return if controller.nil?
    pages = site.cached_pages.find_by_reference_key('Section', record.section_id)
    site.expire_cached_pages controller, "Expired pages referenced by Section ##{record.section_id}", pages
  end
  
  alias after_create after_destroy
end