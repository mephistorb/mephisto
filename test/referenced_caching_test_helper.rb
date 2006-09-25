module Mephisto # :nodoc:
  module Caching # :nodoc:
    module ReferencedCachingTestHelper
      # Prepares a caching directory for use.  Put this in your test case's #setup method.
      # Be sure to CHANGE the page_cache_directory in config/environments/test.rb, otherwise
      # this will remove your complete public directory
      def prepare_for_caching!
        FileUtils.rm_rf   ActionController::Base.page_cache_directory rescue nil
        FileUtils.mkdir_p ActionController::Base.page_cache_directory
      end

      def assert_caches_pages(*urls)
        yield(urls) if block_given?
        urls.map { |url| assert_cached url }
      end

      def assert_expires_pages(*urls)
        yield(urls) if block_given?
        urls.map { |url| assert_not_cached url }
      end

      # Asserts a page was cached.
      def assert_cached(url)
        assert page_cache_exists?(url), "#{url} is not cached"
      end

      # Asserts a page was not cached.
      def assert_not_cached(url)
        assert !page_cache_exists?(url), "#{url} is cached"
      end

      alias assert_caches_page  assert_caches_pages
      alias assert_expires_page assert_expires_pages

      private
        # Gets the page cache filename given a relative URL like /blah
        def page_cache_file(url)
          ActionController::Base.send :page_cache_file, url.gsub(/^https?:\/\//, '')
        end

        # Gets a test page cache filename given a relative URL like /blah
        def page_cache_test_file(url)
          File.join ActionController::Base.page_cache_directory, page_cache_file(url).reverse.chomp('/').reverse
        end

        # Returns true/false whether the page cache file exists.
        def page_cache_exists?(url)
          File.exists? page_cache_test_file(url)
        end
    end
  end
end