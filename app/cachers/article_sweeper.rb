class ArticleSweeper < ActionController::Caching::Sweeper
  include Mephisto::SweeperMethods
  observe Article

  def after_create(record)
    expire_assigned_sections!(record) unless controller.nil? || record.status != :published
  end

  def after_save(record)
    return if controller.nil?
    expire_overview_feed! if record.is_a?(Article)
    pages = CachedPage.find_by_reference(record)
    expire_cached_pages "Expired pages referenced by #{record.class} ##{record.id}", *pages
  end

  alias after_destroy after_save
end