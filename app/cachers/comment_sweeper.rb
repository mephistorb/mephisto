class CommentSweeper < ActionController::Caching::Sweeper
  include Mephisto::SweeperMethods
  observe Comment

  # only sweep updates, not creations
  # tagged 'lame hack'
  def before_save(record)
    @new = record.new_record?
  end

  def after_save(record)
    return if controller.nil? || (@new && !record.approved?)
    expire_overview_feed!
    pages = CachedPage.find_by_reference(record.article)
    expire_cached_pages "Expired pages referenced by #{record.class} ##{record.id}", *pages
  end
end