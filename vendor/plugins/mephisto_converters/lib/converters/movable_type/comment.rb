module MovableType
  class Comment < ActiveRecord::Base
    set_table_name 'mt_comment'
    set_primary_key 'comment_id'
    establish_connection configurations['mt3']

    belongs_to :entry, :foreign_key => 'comment_entry_id', :class_name => 'MovableType::Entry'
    belongs_to :blog, :foreign_key => 'comment_blog_id', :class_name => 'MovableType::Blog'
    belongs_to :author, :foreign_key => 'comment_commenter_id', :class_name => 'MovableType::Author'
  end
end