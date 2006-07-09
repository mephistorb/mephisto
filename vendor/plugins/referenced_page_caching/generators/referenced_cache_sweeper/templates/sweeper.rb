class <%= class_name %>Sweeper < ActionController::Caching::Sweeper
  # Specify which ActiveRecord models to observe
  # observe Article, Comment

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
  #def after_create(record)
  #  controller.class.expire_page('/')
  #end
  
  # Another example showing how to expire references for an associated record
  # Note that this example will clobber the other example after_create method if both are uncommented.
  #def after_create(comment)
  #  after_save(comment.article)
  #end
end