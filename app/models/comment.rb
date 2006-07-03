class Comment < Content
  validates_presence_of :author, :author_ip, :article_id
  before_create  { |comment| comment.site_id = comment.article.site_id }
  before_create  :check_comment_expiration
  before_save    :update_counter_cache
  before_destroy :decrement_counter_cache
  belongs_to :article
  attr_protected :approved

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
  
  def approved=(value)
    @old_approved ||= approved? ? :true : :false
    write_attribute :approved, value
  end

  protected
    def check_comment_expiration
      raise Article::CommentNotAllowed unless article.comments_allowed?
    end

    def update_counter_cache
      Article.increment_counter 'comments_count', article_id if approved? && @old_approved == :false
      Article.decrement_counter 'comments_count', article_id if !approved? && @old_approved == :true
    end
    
    def decrement_counter_cache
      Article.decrement_counter 'comments_count', article_id if approved?
    end
end
