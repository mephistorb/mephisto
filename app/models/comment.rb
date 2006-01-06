class Comment < Article
  belongs_to :article, :counter_cache => true
  before_save :cache_redcloth

  def to_liquid
    { 'author'       => author,
      'author_url'   => author_url,
      'author_email' => author_email,
      'author_ip'    => author_ip,
      'body'         => description_html,
      'created_at'   => created_at }
  end

  protected
  validates_presence_of :description, :author, :author_ip
end
