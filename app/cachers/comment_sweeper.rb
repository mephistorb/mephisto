class CommentSweeper < ActionController::Caching::Sweeper
  include Mephisto::SweeperMethods
  observe Comment

  def after_update(record)
    return if controller.nil?
    expire_overview_feed!
    pages = CachedPage.find_by_reference(record.article)
    expire_cached_pages "Expired pages referenced by #{record.class} ##{record.id}", *pages
  end
end