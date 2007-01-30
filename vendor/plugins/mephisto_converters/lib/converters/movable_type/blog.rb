module MovableType
  class Blog < ActiveRecord::Base
    set_table_name 'mt_blog'
    set_primary_key 'blog_id'
    establish_connection configurations['mt3']
    
    has_many :entries, :foreign_key => 'entry_blog_id', :class_name => 'MovableType::Entry'
  end
end
