class Event < ActiveRecord::Base
  validates_presence_of :article_id
  validate :require_content_and_user
  belongs_to :article, :foreign_key => 'article_id'
  belongs_to :user

  protected
  def require_content_and_user
    errors.add_to_base "Title or Body must be changed"              unless %w(publish comment).include?(mode) || article.changed?(:title) || article.changed?(:body)
    errors.add_to_base "User must be provided for Article events"   unless mode == 'comment' || user_id
    errors.add_to_base "Author must be provided for Comment events" unless mode != 'comment' || author
  end
end
