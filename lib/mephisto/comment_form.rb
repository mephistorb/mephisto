module Mephisto
  class CommentForm < Liquid::Block
    include Reloadable
    include ActionView::Helpers::TagHelper
    include ActionView::Helpers::FormTagHelper
    
    def render(context)
      result = []
      context.stack do
        errors = context['errors'] ? %Q{<ul id="comment_errors"><li>#{context['errors'].join('</li><li>')}</li></ul>} : ''
        
        context['form'] = {
          'body'   => text_area_tag('comment_description',   nil, :name => 'comment[description]'),
          'name'   => text_field_tag('comment_author',       nil, :name => 'comment[author]'),
          'email'  => text_field_tag('comment_author_email', nil, :name => 'comment[author_email]'),
          'url'    => text_field_tag('comment_author_url',   nil, :name => 'comment[author_url]'),
          'submit' => submit_tag('Send')
        }

        result << content_tag(:form, [errors]+render_all(@nodelist, context), :method => :post, :action => "#{context['article']['url']}/comment")
      end
      result
    end
  end
end