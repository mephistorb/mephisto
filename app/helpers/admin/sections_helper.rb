module Admin::SectionsHelper
  def pluralize_articles_count_for(section)
    pluralize @article_count ? (@article_count[section.id.to_s] || 0) : section.articles_count, 'article'
  end
end
