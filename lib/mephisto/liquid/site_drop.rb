module Mephisto
  module Liquid
    class SiteDrop < ::Liquid::Drop
      include Reloadable

      def initialize(site)
        @site = site
      end

      def sections
        @sections ||= @site.sections.inject([]) { |all, s| all.send(s.home? ? :unshift : :<<, s.to_liquid) }
      end
    end
  end
end