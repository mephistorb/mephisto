STATS_DIRECTORIES << %w(Liquid\ Drops app/drops) << %w(Liquid\ Filters app/filters) << %w(Observers/Sweeprs app/cachers)

namespace :cache do
  desc "Clear page cache for one or more sites.  (rake cache:clear ID=1,2 HOST=foo.com)"
  task :clear => :environment do
    require 'application'
    sites = []
    sites += Site.find(ENV['ID'].split(',')) if ENV['ID']
    sites += Site.find(:all, :conditions => ['host IN (?)', ENV['HOST'].split(',')]) if ENV['HOST']
    sites  = Site.find(:all) if sites.empty?
    sites.each do |site|
      ApplicationController.page_cache_directory = site.page_cache_directory.to_s
      puts site.expire_cached_pages(ApplicationController, "Clearing page cache for '#{site.title || "site #{site.id}"}'")
    end
  end
end