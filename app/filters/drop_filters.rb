module DropFilters
  def section(path)
    @context['site'].find_section(path)
  end
  
  def child_sections(path_or_section)
    path = path_or_section.is_a?(SectionDrop) ? path_or_section['path'] : path_or_section
    @context['site'].find_child_sections(path)
  end

  def latest_articles(site_or_section, limit = nil)
    site_or_section.latest_articles(limit || site_or_section['articles_per_page'])
  end

  def latest_article(section)
    latest_articles(section, 1).first
  end
  
  def latest_comments(site, limit = nil)
    site.latest_comments(limit || site['articles_per_page'])
  end
end