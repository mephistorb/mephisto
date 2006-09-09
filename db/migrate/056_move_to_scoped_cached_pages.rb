class MoveToScopedCachedPages < ActiveRecord::Migration
  def self.up
    if Site.multi_sites_enabled
      Site.find(:all).each do |site|
        say_with_time "sweeping for #{site.title}..." do
          expire_pages site.host, site.cached_pages
        end
      end
    else
      say_with_time "sweeping cached pages" do
        expire_pages '', CachedPage.find(:all)
      end
    end
  end

  def self.down
  end
  
  def self.expire_pages(prefix, pages)
    pages.each do |page|
      ActionController::Base.expire_page "/#{prefix}#{page.url}"
    end
    CachedPage.destroy_all ['id in (?)', pages.collect(&:id)]
  end
end
