module Mephisto
  module SpamDetectionEngines
    class DefensioEngine < Mephisto::SpamDetectionEngine::Base
      def valid?
        [:defensio_url, :defensio_key].all? {|key| options.has_key?(key)}
      end

      def valid_key?
      end

      def ham?(request, comment)
        defensio
      end

      def mark_as_ham(request, comment)
        defensio.mark_as_ham(comment)
      end

      def mark_as_spam(request, comment)
        defensio.mark_as_spam(comment)
      end

      # The Defensio service supports statistics.
      def statistics
      end

      protected
      def defensio
        begin
        @defensio ||= Defensio::Client.new(:owner_url => options[:defensio_url], :api_key => options[:defensio_key])
        rescue Defensio::InvalidAPIKey
          logger.warn { $! }
          logger.warn { $!.backtrace.join("\n") }
          raise Mephisto::SpamDetectionEngine::NotConfigured
        end
      end
    end
  end
end
