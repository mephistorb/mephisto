module Mephisto
  module SweeperMethods
    mattr_accessor :cache_sweeper_tracing

    def self.expire_cached_pages(log_message, controller, *pages)
      if cache_sweeper_tracing
        controller.logger.warn log_message
        controller.logger.warn "Expiring #{pages.size} page(s)"
        pages.each do |page|
          controller.logger.warn " - #{page.url}"
        end
      end
      if pages.any?
        pages.each { |p| controller.class.expire_page(p.url) }
      end
    end

    def expire_cached_pages(log_message, *pages)
      SweeperMethods.expire_cached_pages(log_message, controller, *pages)
    end

    def expire_overview_feed!
      if cache_sweeper_tracing
        controller.logger.warn "Expiring Overview Feed: #{overview_path}"
      end
      controller.class.expire_page overview_path
    end

    def expire_assigned_sections!(record)
      record.send :save_assigned_sections
      record.sections.each do |section|
        controller.expire_page :sections => section.to_url,      :controller => '/mephisto', :action => 'list'
        controller.expire_page :sections => section.to_feed_url, :controller => '/feed',     :action => 'feed'
      end
    end
  end
end