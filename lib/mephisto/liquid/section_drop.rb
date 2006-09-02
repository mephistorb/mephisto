module Mephisto
  module Liquid
    class SectionDrop < ::Liquid::Drop
      include UrlMethods
      include DropMethods
      
      def section() @source end
      def current() @current == true end

      def initialize(source, current = false)
        @source         = source
        @current        = current
        @section_liquid = [:id, :name, :path, :articles_count].inject({}) { |h, k| h.merge k.to_s => @source.send(k) }
      end

      def before_method(method)
        @section_liquid[method.to_s]
      end
      
      def url
        @url ||= absolute_url(*@source.to_url)
      end

      def is_blog
        @source.blog?
      end
      
      def is_paged
        @source.paged?
      end

      def is_home
        @source.home?
      end
    end
  end
end