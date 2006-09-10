module Mephisto
  module Liquid
    class SiteDrop < ::Liquid::Drop
      include DropMethods
      
      def site() @source end
      def current_section() @current_section_liquid end

      def initialize(source, section = nil)
        @source                 = source
        @current_section        = section
        @current_section_liquid = section ? section.to_liquid : nil
        @site_liquid = [:id, :host, :subtitle, :title, :articles_per_page, :archive_slug, :tag_slug, :search_slug].inject({}) { |h, k| h.merge k.to_s => @source.send(k) }
        @site_liquid['accept_comments'] = @source.accept_comments?
      end

      def before_method(method)
        @site_liquid[method.to_s]
      end

      def sections
        @sections ||= @source.sections.inject([]) { |all, s| all.send(s.home? ? :unshift : :<<, s.to_liquid(s == @current_section)) }
      end
      
      def blog_sections
        sections.select { |s| s.section.blog? }
      end
      
      def page_sections
        sections.select { |s| s.section.paged? }
      end
      
      def tags
        @tags ||= @source.tags.collect &:name
      end
    end
  end
end