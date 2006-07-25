module Mephisto
  module Liquid
    class SectionDrop < ::Liquid::Drop
      include Reloadable

      def initialize(section)
        @section        = section
        @section_liquid = [:id, :name, :permalink].inject({}) { |h, k| h.merge k.to_s => section.send(k) }
      end

      def before_method(method)
        @section_liquid[method.to_s]
      end
      
      def url
        @url ||= '/' + @section.to_url.join('/')
      end
    end
  end
end