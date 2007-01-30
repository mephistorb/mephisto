module MovableType
  class Placement < ActiveRecord::Base
    set_table_name 'mt_placement'
    set_primary_key 'placement_id'
    establish_connection configurations['mt3']

    belongs_to :blog, :foreign_key => 'placement_blog_id', :class_name => 'MovableType::Blog'
    belongs_to :entry, :foreign_key => 'placement_entry_id', :class_name => 'MovableType::Entry'
    belongs_to :category, :foreign_key => 'placement_category_id', :class_name => 'MovableType::Category'
  end
end
