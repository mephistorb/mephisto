module Mephisto
  module Liquid
    class ArticleDrop < ::Liquid::Drop
      attr_reader :article

      def initialize(article, mode)
        @article        = article
        @article_liquid = { 
          'id'               => article.id,
          'title'            => article.title,
          'permalink'        => article.permalink,
          'url'              => article.full_permalink,
          'body'             => article.send(:body_for_mode, mode),
          'published_at'     => article.site.timezone.utc_to_local(article.published_at),
          'updated_at'       => article.site.timezone.utc_to_local(article.updated_at),
          'comments_count'   => article.comments_count,
          'author'           => article.user.to_liquid,
          'accept_comments'  => article.accept_comments?
        }
      end

      def before_method(method)
        @article_liquid[method.to_s]
      end
      
      def sections
        @sections ||= @article.sections.inject([]) { |all, s| s.home? ? all : all << s.to_liquid } # your days are numbered, home section!
      end

      def blog_sections
        sections.select { |s| s.section.blog? }
      end
      
      def page_sections
        sections.select { |s| s.section.paged? }
      end
    end
  end
end