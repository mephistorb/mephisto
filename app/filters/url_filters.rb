require 'digest/md5'
module UrlFilters
  include Mephisto::Liquid::UrlMethods
  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::AssetTagHelper

  def link_to_article(article)
    content_tag :a, article['title'], :href => article['url']
  end
  
  def link_to_page(page, section = nil)
    content_tag :a, page_title(page), page_anchor_options(page, section)
  end

  def link_to_comments(article)
    content_tag :a, pluralize(article['comments_count'], 'comment'), :href => article['url']
  end
  
  def link_to_section(section)
    content_tag :a, section['name'], :href => section['url'], :title => section['title']
  end

  def img_tag(img, options = {})
    tag 'img', {:src => asset_url(img), :alt => img.split('.').first }.merge(options)
  end
  
  def stylesheet_url(css)
    absolute_url :stylesheets, css
  end
  
  def javascript_url(js)
    absolute_url :javascripts, js
  end
  
  def asset_url(asset)
    absolute_url :images, asset
  end

  def stylesheet(stylesheet, media = nil)
    stylesheet << '.css' unless stylesheet.include? '.'
    tag 'link', :rel => 'stylesheet', :type => 'text/css', :href => stylesheet_url(stylesheet), :media => media
  end

  def javascript(javascript)
    javascript << '.js' unless javascript.include? '.'
    content_tag 'script', '', :type => 'text/javascript', :src => javascript_url(javascript)
  end

  def gravatar(comment, size=80, default=nil)
    return '' unless comment['author_email']
    url = "http://www.gravatar.com/avatar.php?size=#{size}&gravatar_id=#{Digest::MD5.hexdigest(comment['author_email'])}"
    url << "&default=#{default}" if default

    image_tag url, :class => 'gravatar', :size => "#{size}x#{size}", :alt => comment['author']
  end

  def link_to_tag(tag)
    content_tag :a, tag, :href => tag_url(tag)
  end

  def link_to_month(section, date = nil, format = 'my')
    content_tag :a, format_date(date, format), :href => monthly_url(section, date)
  end

  def monthly_url(section, date = nil)
    date = parse_date(date)
    archive_url(section, date.year.to_s, date.month.to_s)
  end

  def archive_url(section, *pieces)
    File.join(section.url, section['archive_path'], *pieces)
  end

  def tag_url(*tags)
    tags = [tags] ; tags.flatten!
    absolute_url @context['site'].source.tag_url(*tags)
  end

  def search_url(query, page = nil)
    absolute_url @context['site'].source.search_url(query, page)
  end

  def page_url(page, section = nil)
    section ||= current_page_section
    page[:is_page_home] ? section.url : [section.url, page[:permalink]].join('/')
  end

  private
    # marks a page as class=selected
    def page_anchor_options(page, section = nil)
      options = {:href => page_url(page, section)}
      current_page_article == page ? options.update(:class => 'selected') : options
    end
    
    def current_page_section
      @current_page_section ||= @context['section']
    end
    
    def current_page_article
      @current_page_article ||= @context['article']
    end
end