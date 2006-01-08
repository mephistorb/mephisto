class TemplateSweeper < ActionController::Caching::Sweeper
  observe Template

  def after_save(record)
    controller.class.benchmark "Expired all referenced pages" do
      CachedPage.find(:all).each { |p| controller.class.expire_page(p.url) }
      CachedPage.delete_all
    end
  end
end