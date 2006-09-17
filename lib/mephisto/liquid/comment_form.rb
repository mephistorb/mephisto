module Mephisto
  module Liquid
    class CommentForm < ::Liquid::Block
      cattr_accessor :article
    
      def render(context)
        return '' unless article.accept_comments?
        result = []
        context.stack do
          if context['message'].blank? 
            errors = context['errors'].blank? ? '' : %Q{<ul id="comment-errors"><li>#{context['errors'].join('</li><li>')}</li></ul>}

            submitted = context['submitted'] || {}
            submitted.each{ |k, v| submitted[k] = CGI::escapeHTML(v) }
            
            context['form'] = {
              'body'   => %(<textarea id="comment_body" name="comment[body]">#{submitted['body']}</textarea>),
              'name'   => %(<input type="text" id="comment_author" name="comment[author]" value="#{submitted['author']}" />),
              'email'  => %(<input type="text" id="comment_author_email" name="comment[author_email]" value="#{submitted['author_email']}" />),
              'url'    => %(<input type="text" id="comment_author_url" name="comment[author_url]" value="#{submitted['author_url']}" />),
              'submit' => %(<input type="submit" value="Send" />)
            }
            
            result << %(<form id="comment-form" method="post" action="#{context['article'].url}/comments#comment-form">#{[errors]+render_all(@nodelist, context)}</form>)
          else
            result << %(<p id="comment-message">#{context['message']}</p>)
          end
        end
        result
      end
    end
  end
end
