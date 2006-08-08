module Mephisto
  module Liquid
    class SiteDrop < ::Liquid::Drop
      include Reloadable

      attr_reader :site

      def initialize(site)
        @site = site
        @site_liquid = [:id, :host, :subtitle, :title].inject({}) { |h, k| h.merge k.to_s => site.send(k) }
        @site_liquid['accept_comments'] = @site.accept_comments?
      end

      def before_method(method)
        @site_liquid[method.to_s]
      end

      def sections
        @sections ||= @site.sections.inject([]) { |all, s| all.send(s.home? ? :unshift : :<<, s.to_liquid) }
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