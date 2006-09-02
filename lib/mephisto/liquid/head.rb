module Mephisto
  module Liquid
    class Head < ::Liquid::Block
      include UrlMethods
      include ActionView::Helpers::TagHelper
    
      def render(context)
        result = []
        context.stack do
          context['head'] = {
            'feed' => tag(:link, :rel => 'alternate', :type => 'application/atom+xml', :href => absolute_url('feed/atom.xml'))
          }

          result << content_tag(:head, render_all(@nodelist, context))
        end
        result
      end
    end
  end
end