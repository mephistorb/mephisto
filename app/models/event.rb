class Event < ActiveRecord::Base
  validates_presence_of :article_id, :site_id
  validate :content_and_user_added

  # article being updated
  belongs_to :article, :foreign_key => 'article_id'

  # updater of the article at the time of the event
  belongs_to :user, :with_deleted => true
  
  belongs_to :comment
  belongs_to :site

  def self.mode_from(record)
    case
      when record.is_a?(Comment) then 'comment'
      when record.new_record?    then 'publish'
      else 'edit'
    end
  end

  protected
    def content_and_user_added
      errors.add_to_base "Title or Body must be changed" unless %w(publish comment).include?(mode) || article.title_changed? || article.body_changed?
      errors.add_to_base "User must be provided for Article events"   unless (mode == 'comment' && author) || user_id
    end
end
