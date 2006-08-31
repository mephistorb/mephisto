module WordPress
  class Post < ActiveRecord::Base
    set_table_name 'wp_posts'
    set_primary_key 'ID'
    establish_connection configurations['wp']
    has_many :comments, :foreign_key => 'comment_parent', :class_name => 'WordPress::Comment'
   
    def categories
      category_ids = WordPress::PostCategory.find_all_by_post_id(self.ID)
      categories = category_ids.inject([]) {|categories, postcat| categories << WordPress::Category.find_by_cat_ID(postcat.category_id) }
      categories
    end

    def comments
      WordPress::Comment.find_all_by_comment_post_ID(self.ID)
    end
  end
end