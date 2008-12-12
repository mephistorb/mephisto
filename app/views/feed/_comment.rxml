xm.entry 'xml:base' => home_url do
  xm.author do
    xm.name comment.author
  end
  xm.id        "tag:#{request.host_with_port},#{article.published_at.to_date.to_s :db}:#{article.id}:#{comment.id}"
  xm.published comment.created_at.xmlschema
  xm.updated   comment.created_at.xmlschema
  article.sections.each do |section|
    xm.category "term" => section.name unless section.home?
  end
  xm.link "rel" => "alternate", "type" => "text/html",
    "href" => "http://#{request.host_with_port}#{relative_url_root}#{section_url_for article}"
  xm.title "Comment on '#{strip_tags(article.title)}' by #{comment.author}"
  xm << %{<content type="html">#{sanitize_feed_content comment.body_html}</content>}
end