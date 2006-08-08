class AssignedSectionSweeper < ActionController::Caching::Sweeper
  include Mephisto::SweeperMethods
  observe AssignedSection

  def after_destroy(record)
    return if controller.nil?
    pages = CachedPage.find_by_reference_key('Section', record.section_id)
    expire_cached_pages "Expired pages referenced by Section ##{record.section_id}", *pages
  end
  
  alias after_create after_destroy
end