class Comment < Article
  belongs_to :article, :counter_cache => true

  def to_liquid
    { 'id'         => id,
      'author'     => author_link,
      'body'       => body_html,
      'created_at' => created_at }
  end

  def author_link
    return author if author_url.blank?
    self.author_url = "http://" + author_url unless author_url =~ /^https?:\/\//
    %Q{<a href="#{author_url}">#{author}</a>}
  end

  protected
  validates_presence_of :body, :author, :author_ip
end
