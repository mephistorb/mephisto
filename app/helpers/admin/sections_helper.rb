module Admin::SectionsHelper
  def options_from_templates_for_select(templates, selected = nil)
    '<option value="0">-- default --</option>' +
    options_for_select(templates.inject([]) { |options, template| options << template.basename.to_s.split('.').first }, selected.to_s)
  end

  def pluralize_articles_count_for(section)
    pluralize @article_count ? (@article_count[section.id.to_s] || 0) : section.articles_count, 'article'
  end
end
