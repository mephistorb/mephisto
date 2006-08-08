class TemplateSweeper < ActionController::Caching::Sweeper
  include Mephisto::SweeperMethods
  observe Template

  # only sweep updates, not creations
  # tagged 'lame hack'
  def before_save(record)
    @new = record.new_record?
  end

  def after_save(record)
    expire_cached_pages "Expired all referenced pages", *CachedPage.find(:all) if @new.nil? && controller
  end
end