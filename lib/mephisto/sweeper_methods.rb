module Mephisto
  module SweeperMethods
    def expire_overview_feed!
      if Site.cache_sweeper_tracing
        controller.logger.warn "Expiring Overview Feed: #{overview_path}"
      end
      controller.class.expire_page overview_path
    end

    def expire_assigned_sections!(record)
      record.send :save_assigned_sections
      record.sections.each do |section|
        controller.expire_page :path     => section.to_url,      :controller => '/mephisto', :action => 'dispatch'
        controller.expire_page :sections => section.to_feed_url, :controller => '/feed',     :action => 'feed'
      end
    end
  end
end