class Event < ActiveRecord::Base
  validates_presence_of :article_id, :user
  belongs_to :article
  belongs_to :user
end
