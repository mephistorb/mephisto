module Admin::ThemesHelper
  def theme_author_link theme
    author = theme.author || 'unknown'
    homepage = theme.homepage
    homepage.blank? ? h(author) : link_to(h(author), homepage)
  end
end
