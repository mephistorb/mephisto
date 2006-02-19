class TemplateSweeper < ActionController::Caching::Sweeper
  observe Template, LayoutTemplate

  # only sweep updates, not creations
  # tagged 'lame hack'
  def before_save(record)
    @new = record.new_record?
  end

  def after_save(record)
    return if @new
    controller.class.benchmark "Expired all referenced pages" do
      CachedPage.find(:all).each { |p| controller.class.expire_page(p.url) }
      CachedPage.delete_all
    end
  end
end