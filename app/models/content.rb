class Content < ActiveRecord::Base
  filtered_column :body, :excerpt, :only => :textile_filter
  validates_presence_of :body
  belongs_to :user
  belongs_to :site
end