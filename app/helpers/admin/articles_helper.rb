module Admin::ArticlesHelper
  FILTER_TYPES = %w(approved unapproved) unless const_defined?(:FILTER_TYPES)

  def status_icon
    @status_icon ||= { :unpublished => %w(orange bstop.gif),
                       :pending     => %w(yellow document.gif),
                       :published   => %w(green check.gif) }
  end

  def link_to_article(article)
    article.published? ?
      link_to(h(article.title), article_url(article.hash_for_permalink)) :
      h(article.title)
  end

  def published_at_for(article)
    format = utc_to_local(article.published_at).year == Time.now.year ? :plain : :standard
    article.published? ? utc_to_local(article.published_at).to_s(format) : "not published"
  end

  def valid_filter?(filter = params[:filter])
    FILTER_TYPES.include? filter
  end
end
