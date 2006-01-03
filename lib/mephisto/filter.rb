module Mephisto
  module Filter
    def link_to_article(article)
      %Q{<a href="#{article['url']}">#{article['title']}</a>}
    end
    
    def textilize(text)
      return '' if text.blank?
      textilized = RedCloth.new(text, [ :hard_breaks ])
      textilized.hard_breaks = true if textilized.respond_to?("hard_breaks=")
      textilized.to_html
    end
  end
end