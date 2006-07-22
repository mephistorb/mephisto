module Mephisto
  module Liquid
    class ArticleDrop < ::Liquid::Drop
      include Reloadable

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
          'comments_allowed' => article.comments_allowed?
        }
      end

      def before_method(method)
        @article_liquid[method.to_s]
      end
      
      def sections
        @sections ||= @article.sections.inject([]) { |all, s| s.home? ? all : all << s.to_liquid } # your days are numbered, home section!
      end
    end
  end
end