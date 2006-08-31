module WordPress
  class PostCategory < ActiveRecord::Base
    set_table_name 'wp_post2cat'
    set_primary_key 'rel_id'
    establish_connection configurations['wp']
    belongs_to :category, :class_name => 'WordPress::Category', :foreign_key => 'category_id'
    belongs_to :post, :class_name => 'WordPress::Post', :foreign_key => 'post_id'
  end
end