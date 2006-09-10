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
        @section_liquid['articles_count'] = @source.send(:read_attribute, :articles_count)
        {:is_blog => :blog?, :is_paged => :paged?, :is_home => :home?}.each { |k, v| @section_liquid[k.to_s] = @source.send(v) }
      end

      def before_method(method)
        @section_liquid[method.to_s]
      end
      
      def url
        @url ||= absolute_url(*@source.to_url)
      end
      
      def earliest_month
        @earliest_month ||= @source.articles.find(:first, :order => 'published_at').published_at.beginning_of_month.to_date rescue :false
      end
      
      def months
        if @months.nil?
          this_month = Time.now.utc.beginning_of_month.to_date
          date       = earliest_month.is_a?(Date) && earliest_month
          @months = []
          while date && date <= this_month
            @months << date
            date = date >> 1
          end
          @months.reverse!
        end
        
        @months
      end
    end
  end
end