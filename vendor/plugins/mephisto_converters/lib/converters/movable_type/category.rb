module MovableType
  class Category < ActiveRecord::Base
    set_table_name 'mt_category'
    set_primary_key 'category_id'
    establish_connection configurations['mt3']

    belongs_to :blog, :foreign_key => 'category_blog_id', :class_name => 'MovableType::Blog'
    has_many :entries, :foreign_key => 'category_entry_id', :class_name => 'MovableType::Entry'

  end
end
