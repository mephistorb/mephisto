class AssetSweeper < ActionController::Caching::Sweeper
  include Mephisto::SweeperMethods
  #observe Resource
  def after_save(record)
    return if controller.nil?
    pages = CachedPage.find_by_reference(record)
    expire_cached_pages "Expired pages referenced by #{record.class} ##{record.id}", *pages
  end
  alias after_destroy after_save
end