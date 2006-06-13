class Comment < Content
  validates_presence_of :author, :author_ip
  before_save    :increment_counter_cache
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
    def increment_counter_cache
      Article.increment_counter 'comments_count', article_id if approved? && @old_approved == :false
      decrement_counter_cache if !approved? && @old_approved == :true
    end
    
    def decrement_counter_cache
      Article.decrement_counter 'comments_count', article_id if approved?
    end
end