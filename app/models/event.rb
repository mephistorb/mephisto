class Event < ActiveRecord::Base
  validates_presence_of :article_id
  validate :content_and_user_added

  # article being updated
  belongs_to :article, :foreign_key => 'article_id'

  # updater of the article at the time of the event
  belongs_to :user

  with_options :to => :article do |s|
    s.delegate :author
    s.delegate :author_url
    s.delegate :author_email
    s.delegate :author_ip
  end

  protected
  def content_and_user_added
    errors.add_to_base "Title or Body must be changed" unless %w(publish comment).include?(mode) || article.changed?(:title) || article.changed?(:body)
    errors.add_to_base "User must be provided for Article events"   unless mode == 'comment' || user_id
  end
end
