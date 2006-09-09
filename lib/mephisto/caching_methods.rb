module Mephisto # :nodoc:
  module CachingMethods
    def self.included(base)
      base.helper_method :cached_references
      base.extend ClassMethods
      base.send :attr_writer, :cached_references
    end

    module ClassMethods
      # Caches the actions using the page-caching approach and saves the references for the page
      def caches_page_with_references(*actions)
        return unless perform_caching
        caches_page *actions
        after_filter :cache_page_with_references, :only => actions
      end
    end

    protected
      # An array of the current page's references.
      #
      #   self.cached_references << @post
      #   self.cached_references += @post.comments
      # 
      def cached_references
        @cached_references ||= []
      end
      
      # Saves a CachedPage for the current request with the current references.  This is called in an after filter if #caches_page_with_references
      # is used.
      def cache_page_with_references
        return unless perform_caching && caching_allowed
        CachedPage.create_by_url(site, url_for(:only_path => true, :skip_relative_url_root => true), cached_references)
      end
  end
end