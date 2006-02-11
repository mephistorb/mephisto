module Admin::ArticlesHelper
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
    article.published? ? article.published_at.to_s(:long) : "not published"
  end
end
