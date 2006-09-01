module FeedHelper
  def sanitize_content(html)
    returning h(sanitize(html)) do |html|
      html.gsub! /&amp;(#\d+);/ do |s|
        "&#{$1};"
      end
    end
  end
end
