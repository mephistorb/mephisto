module Mephisto
  module SpamDetectionEngines
    class DefensioEngine < Mephisto::SpamDetectionEngine::Base
      def ham?(request, comment)
      end

      def mark_as_ham(comment)
      end

      def mark_as_spam(comment)
      end

      # The Defensio service supports statistics.
      def statistics
      end
    end
  end
end
