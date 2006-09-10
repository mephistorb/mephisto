module Mephisto
  module Liquid
    class ArticleDrop < ::Liquid::Drop
      include UrlMethods
      include DropMethods
      
      def article() @source end

      def initialize(source, options = {})
        @options        = options
        @source         = source
        @site           = options.delete(:site)
        @article_liquid = { 
          'id'               => @source.id,
          'title'            => @source.title,
          'permalink'        => @source.permalink,
          'body'             => @source.body_html,
          'excerpt'          => @source.excerpt_html,
          'published_at'     => (@source.site.timezone.utc_to_local(@source.published_at) rescue nil),
          'updated_at'       => (@source.site.timezone.utc_to_local(@source.updated_at)   rescue nil),
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
      
      def content
        @content ||= body_for_mode(@options[:mode] || :list)
      end

      def url
        @url ||= absolute_url(@site.permalink_for(@source))
      end

      protected
        def body_for_mode(mode)
          contents = [before_method(:excerpt), before_method(:body)]
          contents.reverse! if mode == :single
          contents.detect { |content| !content.blank? }.to_s.strip
        end
    end
  end
end