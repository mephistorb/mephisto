class AssetSweeper < ActionController::Caching::Sweeper
  include Mephisto::SweeperMethods
  #observe Resource
  def after_save(record)
    return if controller.nil?
    site.expire_cached_pages controller, "Expired pages referenced by #{record.class} ##{record.id}", site.cached_pages.find_by_reference(record)
  end
  alias after_destroy after_save
end