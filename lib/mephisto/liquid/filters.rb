module Mephisto
  module Liquid
    module Filters
      include ActionView::Helpers::TagHelper

      def link_to_article(article)
        content_tag :a, article['title'], :href => article['url']
      end

      def link_to_comments(article)
        content_tag :a, pluralize(article['comments_count'], 'comment'), :href => article['url']
      end

      def escape_html(html)
        CGI::escapeHTML(html)
      end
      
      alias h escape_html

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
        date ? date.to_s(format.to_sym) : nil
      end
      
      def strftime(date, format)
        date ? date.strftime(format) : nil
      end
      
      def img_tag(img, options = {})
        tag 'img', {:src => "/images/#{img}", :alt => img.split('.').first }.merge(options)
      end
      
      def asset_url(asset)
        "/images/#{asset}"
      end
      
      def stylesheet(stylesheet)
        stylesheet << '.css' unless stylesheet.include? '.'
        tag 'link', :rel => 'stylesheet', :type => 'text/css', :href => "/stylesheets/#{stylesheet}"
      end
      
      def javascript(javascript)
        javascript << '.js' unless javascript.include? '.'
        content_tag 'script', '', :type => 'text/javascript', :src => "/javascripts/#{javascript}"
      end
      
      def month_list
        # XXX cache this someday
        earliest = controller.site.articles.find(:first, :order => 'published_at').published_at.beginning_of_month
      end
      
      
    end
  end
end
