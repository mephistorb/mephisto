module Mephisto
  class CommentForm < Liquid::Block
    include ActionView::Helpers::TagHelper
    include ActionView::Helpers::FormTagHelper

    def render(context)
      result = []
      context.stack do
        context['form'] = {
          'body'   => text_area_tag('description'),
          'name'   => text_field_tag('name'),
          'email'  => text_field_tag('email'),
          'url'    => text_field_tag('url'),
          'submit' => submit_tag('Send')
        }

        result << content_tag(:form, render_all(@nodelist, context), :method => :post)
      end
      result
    end
  end
end