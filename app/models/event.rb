class Event < ActiveRecord::Base
  validates_presence_of :article_id, :user
  validate :require_title_or_body
  belongs_to :article, :foreign_key => 'article_id'
  belongs_to :user

  protected
  def require_title_or_body
    errors.add_to_base "Title or Body must be changed" unless mode == 'publish' || article.changed?(:title) || article.changed?(:body)
  end
end
