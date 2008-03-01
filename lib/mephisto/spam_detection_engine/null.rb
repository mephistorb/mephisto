module Mephisto
  module SpamDetectionEngine
    class Null < Mephisto::SpamDetectionEngine::Base
      def ham?(request, comment)
        true
      end

      def mark_as_ham(comment)
      end

      def mark_as_spam(comment)
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
