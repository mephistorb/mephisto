module Mephisto
  module Liquid
    class SectionDrop < ::Liquid::Drop
      include Reloadable

      attr_reader :section

      def initialize(section)
        @section        = section
        @section_liquid = [:id, :name, :path, :articles_count].inject({}) { |h, k| h.merge k.to_s => section.send(k) }
      end

      def before_method(method)
        @section_liquid[method.to_s]
      end
      
      def url
        @url ||= '/' + @section.to_url.join('/')
      end
      
      def is_home
        @section.home?
      end
    end
  end
end