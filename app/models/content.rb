class Content < ActiveRecord::Base
  filtered_column :body, :excerpt
  belongs_to :user, :with_deleted => true
  belongs_to :site
  [:year, :month, :day].each { |m| delegate m, :to => :published_at }
end