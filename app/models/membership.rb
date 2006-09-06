class Membership < ActiveRecord::Base
  belongs_to :user
  belongs_to :site
  
  validates_presence_of :user_id, :site_id
end
