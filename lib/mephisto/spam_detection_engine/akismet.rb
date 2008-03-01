module Mephisto
  module SpamDetectionEngine
    class Akismet < Mephisto::SpamDetectionEngine::Base
      def ham?(request, comment)
        check_valid!
        !akismet.comment_check(comment_spam_options(request, comment))
      end

      def mark_as_ham(comment, request)
        mark_comment(:ham, comment, request)
      end

      def mark_as_spam(comment, request)
        mark_comment(:spam, comment, request)
      end

      def valid?
        [:akismet_key, :akismet_url].all? { |attr| !options[attr].blank? }
      end

      def valid_key?
        false
      end

      protected
      def akismet
        @akismet ||= Akismet.new(options[:akismet_key], options[:akismet_url])
      end

      def mark_comment(comment_type, site, request)
        check_valid!
        response = akismet.send("submit_#{comment_type}", comment_spam_options(site, request))
      end

      def comment_spam_options(request, comment)
        { :user_ip              => comment.author_ip, 
          :user_agent           => comment.user_agent, 
          :referrer             => comment.referrer,
          :permalink            => "http://#{request.host_with_port}#{site.permalink_for(comment)}", 
          :comment_author       => comment.author, 
          :comment_author_email => comment.author_email, 
          :comment_author_url   => comment.author_url, 
          :comment_content      => comment.body}
      end

      def check_valid!
        raise Mephisto::SpamDetectionEngine::EngineNotConfigured unless self.valid?
      end
    end
  end
end
