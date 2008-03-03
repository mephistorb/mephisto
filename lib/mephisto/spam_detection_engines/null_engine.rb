module Mephisto
  module SpamDetectionEngines
    class NullEngine < Mephisto::SpamDetectionEngine::Base
      def ham?(permalink_url, comment)
        true
      end

      def mark_as_ham(permalink_url, comment)
      end

      def mark_as_spam(permalink_url, comment)
      end

      def valid?
        true
      end

      def valid_key?
        true
      end
    end
  end
end
