module Mephisto
  module SpamDetectionEngines
    class DefensioEngine < Mephisto::SpamDetectionEngine::Base
      Site.register_spam_detection_engine "Defensio", self

      def valid?
        [:defensio_url, :defensio_key].all? {|key| !options[key].blank?}
      end

      def valid_key?
        self.validate_key.success?
      end

      def ham?(permalink_url, comment)
        response = defensio.audit_comment(
          # Required parameters
          :user_ip => comment.author_ip,
          :article_date => comment.article.published_at.strftime("%Y/%m/%d"),
          :comment_author => comment.author,
          :comment_type => "comment",

          # Optional parameters
          :comment_content => comment.body,
          :comment_author_email => comment.author_email,
          :comment_author_url => comment.author_url,
          :permalink => permalink_url,
          :referrer => comment.referrer,
          :user_logged_in => false,
          :trusted_user => false
        )

        comment.update_attribute(:spam_engine_data, {:signature => response.signature, :spaminess => response.spaminess.to_f})
        !response.spam
      end

      def mark_as_ham(permalink_url, comment)
        defensio.report_false_positives(:signatures => [comment.spam_engine_data[:signature]])
      end

      def mark_as_spam(permalink_url, comment)
        defensio.report_false_negatives(:signatures => [comment.spam_engine_data[:signature]])
      end

      # The Defensio service supports statistics.
      def statistics
      end

      def errors
        returning([]) do |es|
          es << "The Defensio key is missing" if options[:defensio_key].blank?
          es << "The Defensio url is missing" if options[:defensio_url].blank?

          unless self.valid_key?
            message = self.validate_key.message
            es << "The Defensio API says your key is invalid#{%Q(: #{message}) unless message.blank?}"
          end
        end
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

      def validate_key
        @response ||= defensio.validate_key
      end
    end
  end
end
