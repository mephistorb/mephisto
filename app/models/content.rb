class Content < ActiveRecord::Base
  filtered_column :body, :excerpt, :only => :textile_filter
  validates_presence_of :body
  belongs_to :user, :with_deleted => true
  belongs_to :site

  def filters=(filters)
    write_attribute :filter, (filters.blank? ? nil : filters.first.to_s)
  end

  def filters
    filter.blank? ? [] : [filter.to_sym]
  end
end