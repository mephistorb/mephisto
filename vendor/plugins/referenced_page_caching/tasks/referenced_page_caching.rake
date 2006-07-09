namespace :cache do
  desc "Clears all cached pages"
  task :clear => :environment do
    ActionController::Base.benchmark "Expired all referenced pages" do
      CachedPage.find(:all).each { |p| ActionController::Base.expire_page(p.url) }
      CachedPage.delete_all
    end
  end
end