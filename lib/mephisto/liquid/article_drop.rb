module Mephisto
  module Liquid
    class ArticleDrop < ::Liquid::Drop
      include DropMethods
      
      def article() @source end

      def initialize(source, options = {})
        @source         = source
        @article_liquid = { 
          'id'               => @source.id,
          'title'            => @source.title,
          'permalink'        => @source.permalink,
          'url'              => @source.full_permalink,
          'body'             => @source.send(:body_for_mode, options[:mode] || :list),
          'excerpt'          => @source.excerpt_html,
          'published_at'     => @source.site.timezone.utc_to_local(@source.published_at),
          'updated_at'       => @source.site.timezone.utc_to_local(@source.updated_at),
          'comments_count'   => @source.comments_count,
          'author'           => @source.user.to_liquid,
          'accept_comments'  => @source.accept_comments?,
          'is_page_home'     => (options[:page] == true)
        }
      end

      def before_method(method)
        @article_liquid[method.to_s]
      end
      
      def sections
        @sections ||= @source.sections.inject([]) { |all, s| s.home? ? all : all << s.to_liquid } # your days are numbered, home section!
      end

      def tags
        @tags ||= @source.tags.collect(&:to_liquid)
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