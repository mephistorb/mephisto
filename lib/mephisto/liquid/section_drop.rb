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
        @section_liquid = [:id, :name, :path].inject({}) { |h, k| h.update k.to_s => @source.send(k) }
        @section_liquid[:articles_count] = @source.send(:read_attribute, :articles_count)
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