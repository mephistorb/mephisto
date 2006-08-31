module WordPress
  class Category < ActiveRecord::Base
    set_table_name 'wp_categories'
    set_primary_key 'cat_ID'
    establish_connection configurations['wp']
    #has_many :posts, :through => :post_categories, :class_name => 'WordPress::Post'
    # user WordPress::Post.find_by_category since hasmanythrough didn't work
    # for some reason. beats me why. gotta check it out later on...
  end
end