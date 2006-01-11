module Mephisto
  class Head < Liquid::Block
    include ActionView::Helpers::TagHelper
    
    def render(context)
      result = []
      context.stack do
        context['head'] = {
          'feed'       => tag(:link, :rel => 'alternate', :type => 'application/atom+xml', :href => '/feed/atom.xml'),
          'javascript' => content_tag(:script, nil, :type => 'text/javascript', :src => '/javascripts/mephisto.js')
        }

        result << content_tag(:head, render_all(@nodelist, context))
      end
      result
    end
  end
end