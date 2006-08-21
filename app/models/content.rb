class Content < ActiveRecord::Base
  filtered_column :body, :excerpt
  validates_presence_of :body
  belongs_to :user, :with_deleted => true
  belongs_to :site
end