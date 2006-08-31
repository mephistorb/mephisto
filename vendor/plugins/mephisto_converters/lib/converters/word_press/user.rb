module WordPress
  class User < ActiveRecord::Base
    set_table_name 'wp_users'
    set_primary_key 'ID'
    establish_connection configurations['wp']
    has_many :posts, :foreign_key => 'post_author', :class_name => 'WordPress::Post'
  end
end