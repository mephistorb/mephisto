class CommentSweeper < ActionController::Caching::Sweeper
  observe Comment

  def after_update(record)
    return if controller.nil?
    controller.class.expire_page overview_url(:only_path => true, :skip_relative_url_root => true)
    pages = CachedPage.find_by_reference(record.article)
    controller.class.benchmark "Expired pages referenced by #{record.class} ##{record.id}" do
      pages.each { |p| controller.class.expire_page(p.url) }
      CachedPage.expire_pages(pages)
    end if pages.any?
  end
end