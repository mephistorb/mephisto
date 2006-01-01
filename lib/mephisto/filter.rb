module Mephisto
  module Filter
    def link_to_article(article)
      %Q{<a href="#{article['url']}">#{article['title']}</a>}
    end
  end
end