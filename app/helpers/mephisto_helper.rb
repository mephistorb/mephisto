# This helper serves as a Liquid Filter module
module MephistoHelper
  def link_to_article(article)
    %Q{<a href="#{article['url']}">#{article['title']}</a>}
  end
end