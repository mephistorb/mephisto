module Mephisto
  module Liquid
    class CommentForm < ::Liquid::Block
      cattr_accessor :article
      include Reloadable
    
      def render(context)
        return '' unless article.comments_allowed?
        result = []
        context.stack do
          if context['message'].blank? 
            errors = context['errors'].blank? ? '' : %Q{<ul id="comment_errors"><li>#{context['errors'].join('</li><li>')}</li></ul>}
            
            context['form'] = {
              'body'   => %(<textarea id="comment_body" name="comment[body]"></textarea>),
              'name'   => %(<input type="text" id="comment_author" name="comment[author]" />),
              'email'  => %(<input type="text" id="comment_author_email" name="comment[author_email]" />),
              'url'    => %(<input type="text" id="comment_author_url" name="comment[author_url]" />),
              'submit' => %(<input type="submit" value="Send" />)
            }
            
            result << %(<form method="post" action="#{context['article']['url']}/comment">#{[errors]+render_all(@nodelist, context)}</form>)
          else
            result << %(<p id="comment-message">#{context['message']}</p>)
          end
        end
        result
      end
    end
  end
end