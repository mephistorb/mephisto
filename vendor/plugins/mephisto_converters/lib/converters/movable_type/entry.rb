module MovableType
  class Entry < ActiveRecord::Base
    set_table_name 'mt_entry'
    set_primary_key 'entry_id'
    establish_connection configurations['mt3']

    belongs_to :blog, :foreign_key => 'entry_blog_id', :class_name => 'MovableType::Blog'
    belongs_to :author, :foreign_key => 'entry_author_id', :class_name => 'MovableType::Author'
    has_many :comments, :foreign_key => 'comment_entry_id', :class_name => 'MovableType::Comment'
    belongs_to :category, :foreign_key => 'entry_category_id', :class_name => 'MovableType::Category'
    has_many :placements, :foreign_key => 'placement_entry_id', :class_name => 'MovableType::Placement'
  end
end