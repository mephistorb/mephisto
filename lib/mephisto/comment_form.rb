module Mephisto
  class CommentForm < Liquid::Block
    def render(context)
      result = []
      context.stack do
        context['form'] = {
          'body'   => %Q{<textarea name="description"></textarea>},
          'name'   => %Q{<input type="text" name="name" />},
          'email'  => %Q{<input type="text" name="email" />}, 
          'url'    => %Q{<input type="text" name="url" />},
          'submit' => %Q{<input type="submit" value="Submit Comment" />}
        }

        result << %Q{<form method="post">}       \
               << render_all(@nodelist, context) \
               << %Q{</form>}
      end
      result
    end
  end
end