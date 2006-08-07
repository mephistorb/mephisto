module Mephisto
  module Liquid
    class SiteDrop < ::Liquid::Drop
      include Reloadable

      attr_reader :site

      def initialize(site)
        @site = site
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