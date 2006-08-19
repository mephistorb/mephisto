# Fix bug where duplicate comment events were created without a timestamp
class FixCommentEventBug < ActiveRecord::Migration
  class Event < ActiveRecord::Base ; end
  def self.up
    Event.update_all ['created_at = ?', Time.now.utc], 'created_at is null'
  end

  def self.down
  end
end
