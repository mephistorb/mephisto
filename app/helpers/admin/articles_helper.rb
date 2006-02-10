module Admin::ArticlesHelper
  def flag_status
    @flag_status ||= { :unpublished => 'flag_red',
                       :pending     => 'flag_yellow',
                       :published   => 'flag_green' }
  end

  def link_to_article(article)
    article.published? ?
      link_to(h(article.title), article_url(article.hash_for_permalink)) :
      '<small>preview link</small>'
  end

  def published_at_for(article)
    article.published? ? article.published_at.to_s(:long) : "not published"
  end
end
