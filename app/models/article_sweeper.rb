class ArticleSweeper < ActionController::Caching::Sweeper
  observe Article, Comment

  def after_save(record)
    pages = CachedPage.find_by_reference(record)
    unless pages.empty?
      controller.class.benchmark "Expired pages referenced by #{record.class} ##{record.id}" do
        pages.each { |p| controller.class.expire_page(p.url) }
        CachedPage.expire_pages(pages)
      end
    end
  end

  # Example of clearing the index when a new record is created
  def after_create(record)
    case record
    when Comment
      after_save(record.article)
    when Article
      record.tags(true).each do |t| 
        expire_page hash_for_tags_url(t.hash_for_url)
      end
    end
  end
end