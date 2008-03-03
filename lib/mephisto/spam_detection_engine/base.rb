module Mephisto
  module SpamDetectionEngine
    class Base
      attr_reader :site, :options, :logger

      def initialize(site)
        @site, @options = site, site.spam_engine_options || {}
        @logger = site.logger
      end

      # Determines if a single comment is either ham or spam.
      def ham?(permalink_url, comment)
        raise SubclassResponsibilityError
      end

      # Marks false positives as ham.
      def mark_as_ham(permalink_url, comment)
        raise SubclassResponsibilityError
      end

      # Marks false negatives as spam.
      def mark_as_spam(permalink_url, comment)
        raise SubclassResponsibilityError
      end

      # Determines if the configuration is valid or not.
      def valid?
        raise SubclassResponsibilityError
      end

      # Contacts the remote service and checks to see if the key is valid.
      def valid_key?
        raise SubclassResponsibilityError
      end

      # Returns an Array of error messages explaining why this spam engine is in an invalid state.
      def errors
      end

      # Returns spam engine statistics about it's performance.
      # This is in Base because not all engines return performance statistics.
      # This default implementation returns an empty Hash, to show no statistics.
      def statistics
        Hash.new
      end
    end
  end
end
