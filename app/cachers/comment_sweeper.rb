class CommentSweeper < ArticleSweeper
  observe Comment

  def after_save(record)
    @event.update_attributes :title => record.article.title, :body => record.body, :site => record.article.site,
      :article => record.article, :author => record.author, :comment => record if record.approved?

    return if controller.nil?
    expire_overview_feed!
    pages = CachedPage.find_by_reference(record.article)
    controller.class.benchmark "Expired pages referenced by #{record.class} ##{record.id}" do
      pages.each { |p| controller.class.expire_page(p.url) }
      CachedPage.expire_pages(pages)
    end if pages.any?
  end

  def after_destroy(record)
    Event.destroy_all ['comment_id = ?', record.id]
  end

  undef :after_create
end