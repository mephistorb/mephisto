xm.entry 'xml:base' => home_url do
  xm.author do
    xm.name article.updater.login
  end
  xm.id        "tag:#{request.host_with_port},#{article.updated_at.to_date.to_s :db}:#{article.id}:#{article.version}"
  xm.published article.published_at.xmlschema if article.published_at
  xm.updated   article.updated_at.xmlschema
  article.sections.each do |section|
    xm.category "term" => section.name unless section.home?
  end if article.respond_to?(:sections)
  article.tags.each do |tag|
    xm.category "term" => tag.name
  end
  xm.link "rel" => "alternate", "type" => "text/html", "href" => "http://#{request.host_with_port}#{site.permalink_for(article)}"
  xm.title     strip_tags(article.title)
  unless article.excerpt_html.blank?
    xm << %{<summary type="html">#{sanitize_feed_content article.excerpt_html}</summary>}
  end
  unless article.body_html.blank?
    xm << %{<content type="html">#{sanitize_feed_content article.body_html}</content>}
  end
end