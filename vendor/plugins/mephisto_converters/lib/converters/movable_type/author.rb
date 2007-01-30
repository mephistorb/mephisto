module MovableType
  class Author < ActiveRecord::Base
    set_table_name 'mt_author'
    set_primary_key 'author_id'
    establish_connection configurations['mt3']

    has_many :comments, :foreign_key => 'comment_author_id', :class_name => 'MovableType::Comment'
  end
end