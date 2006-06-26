module Mephisto
  module Liquid
    class SectionsDrop < ::Liquid::Drop
      include Reloadable

      def initialize(site)
        @site = site
      end

      def list
        @list ||= @site.sections.inject([]) { |all, s| all.send(s.home? ? :unshift : :<<, s.to_liquid) }
      end
    end
  end
end