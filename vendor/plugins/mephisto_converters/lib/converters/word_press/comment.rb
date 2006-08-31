module WordPress
  class Comment < ActiveRecord::Base
    establish_connection configurations['wp']
    set_primary_key 'comment_ID'
    set_table_name 'wp_comments'
    belongs_to :post, :foreign_key => 'comment_parent', :class_name => 'WordPress::Post'
  end
end