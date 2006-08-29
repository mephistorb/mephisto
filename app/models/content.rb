class Content < ActiveRecord::Base
  filtered_column :body, :excerpt
  belongs_to :user, :with_deleted => true
  belongs_to :site
end