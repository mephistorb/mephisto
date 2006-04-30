module Mephisto
  module Liquid
    class PageNavigation < ::Liquid::Block
      include Reloadable
      include ActionView::Helpers::TagHelper

      def render(context)
        collection = context['pages']
        @section   = context['section']
        @page      = context['article']
        result     = []
        context.stack do
          collection.each_with_index do |page, index|
            context['page'] = {
              'link' => content_tag('a', page_title(page, index), page_anchor_options(page, index)),
              'name' => page['title'],
              'url'  => page_url(page, index)
            }
            result << render_all(@nodelist, context)
          end
        end
        result
      end
    
      private
      def page_title(page, index)
        index.zero? ? 'Home' : page['title']
      end
    
      def page_url(page, index)
        "/#{@section}#{'/' + page['permalink'] unless index.zero?}"
      end

      def page_anchor_options(page, index)
        options = {:href => page_url(page, index)}
        @page['id'] == page['id'] ? options.merge(:class => 'selected') : options
      end
    end
  end
end