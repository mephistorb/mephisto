module Mephisto
  module SpamDetectionEngines
    class DefensioEngine < Mephisto::SpamDetectionEngine::Base
      def valid?
        [:defensio_url, :defensio_key].all? {|key| options.has_key?(key)}
      end

      def valid_key?
        defensio.validate_key.success?
      end

      def ham?(request, comment)
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
          :permalink => "http://#{request.host_with_port}#{site.permalink_for(comment)}", 
          :referrer => comment.referrer,
          :user_logged_in => false,
          :trusted_user => false
        )

        comment.update_attribute(:spam_engine_data, {:signature => response.signature, :spaminess => response.spaminess.to_f})
        !response.spam
      end

      def mark_as_ham(request, comment)
        defensio.report_false_positives(:signatures => comment.spam_engine_data[:signature])
      end

      def mark_as_spam(request, comment)
        defensio.report_false_negatives(:signatures => comment.spam_engine_data[:signature])
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
