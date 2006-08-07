module Mephisto
  module Liquid
    class SectionDrop < ::Liquid::Drop
      include Reloadable

      attr_reader :section

      def initialize(section)
        @section        = section
        @section_liquid = [:id, :name, :path, :articles_count].inject({}) { |h, k| h.merge k.to_s => section.send(k) }
      end

      # Liquid Drops can not use #id
      def section_id
        @section_liquid['id']
      end

      def before_method(method)
        @section_liquid[method.to_s]
      end
      
      def url
        @url ||= '/' + @section.to_url.join('/')
      end

      def is_blog
        @section.blog?
      end
      
      def is_paged
        @section.paged?
      end

      def is_home
        @section.home?
      end
    end
  end
end