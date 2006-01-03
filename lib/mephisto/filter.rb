module Mephisto
  module Filter
    def link_to_article(article)
      %Q{<a href="#{article['url']}">#{article['title']}</a>}
    end

    def link_to_comments(article)
      %Q{<a href="#{article['url']}">#{pluralize article['comments_count'], 'comment'}</a>}
    end

    def pluralize(count, singular, plural = nil)
      "#{count} " + if count == 1
        singular
      elsif plural
        plural
      elsif Object.const_defined?("Inflector")
        Inflector.pluralize(singular)
      else
        singular + "s"
      end
    end

    def textilize(text)
      return '' if text.blank?
      textilized = RedCloth.new(text, [ :hard_breaks ])
      textilized.hard_breaks = true if textilized.respond_to?("hard_breaks=")
      textilized.to_html
    end

    def format_date(date, format)
      date.to_s(format.to_sym)
    end
  end
end