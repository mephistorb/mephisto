module FeedHelper  
  # show paged url for an article if the section is a paged section
  def section_url_for(article)
    if @section && @section.show_paged_articles?
      @section_articles ||= {}
      @section_articles[@section.id] ||= (@section.articles.find(:first) || :false)
      ([nil] << (@section_articles[@section.id].permalink == article.permalink ? @section.to_url : @section.to_page_url(article))).join("/")
    else
      site.permalink_for(article)
    end
  end
end
