module Mephisto
  module Liquid
    module Filters
      include ActionView::Helpers::TagHelper

      def link_to_article(article)
        content_tag :a, article['title'], :href => article['url']
      end
      
      def link_to_page(page)
        content_tag :a, page_title(page), page_anchor_options(page)
      end

      def link_to_comments(article)
        content_tag :a, pluralize(article['comments_count'], 'comment'), :href => article['url']
      end
      
      def link_to_section(section)
        content_tag :a, section['name'], :href => section['url']
      end

      def page_title(page)
        page['is_page_home'] ? 'Home' : page['title']
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

      def format_date(date, format, ordinalized = false)
        if ordinalized
          date ? date.to_ordinalized_s(format.to_sym) : nil
        else
          date ? date.to_s(format.to_sym) : nil unless ordinalized
        end
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
       
      private
        # marks a page as class=selected
        def page_anchor_options(page)
          options = {:href => page_url(page)}
          current_page_article.source == page.source ? options.update(:class => 'selected') : options
        end

        def page_url(page)
          page[:is_page_home] ? current_page_section.url : [current_page_section.url, page[:permalink]].join('/')
        end
        
        def current_page_section
          @current_page_section ||= outer_context(:section)
        end
        
        def current_page_article
          @current_page_article ||= outer_context(:article)
        end
        
        # pulls a variable out of the outermost context
        def outer_context(key)
          @context.assigns.last[key.to_s]
        end
    end
  end
end
