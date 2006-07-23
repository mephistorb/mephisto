class Content < ActiveRecord::Base
  filtered_column :body, :excerpt, :only => :textile_filter
  validates_presence_of :body
  belongs_to :user, :with_deleted => true
  belongs_to :site
end