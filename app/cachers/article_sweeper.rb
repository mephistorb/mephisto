class ArticleSweeper < ActionController::Caching::Sweeper
  include Mephisto::SweeperMethods
  observe Article, Section

  def after_save(record)
    return if controller.nil?
    expire_overview_feed! if record.is_a?(Article)
    if record.is_a?(Article) && record.status == :published
      expire_assigned_sections!(record)
    end
    
    if !record.is_a?(Article) || record.status == :published
      site.expire_cached_pages controller, "Expired pages referenced by #{record.class} ##{record.id}", site.cached_pages.find_by_reference(record)
    end
  end

  alias after_destroy after_save
end