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
    expire_cache_for record
  end
  
  def after_destroy(record)
    return if controller.nil?
    expire_overview_feed!
    expire_cache_for record if record.approved?
  end
  
  protected
    def expire_cache_for(comment)
      pages = CachedPage.find_by_references(comment, comment.article)
      expire_cached_pages "Expired pages referenced by #{comment.class} ##{comment.id}", *pages
    end
end