module WordPress
  class Post < ActiveRecord::Base
    set_table_name 'wp_posts'
    set_primary_key 'ID'
    establish_connection configurations['wp']
    has_many :comments, :foreign_key => 'comment_parent', :class_name => 'WordPress::Comment'
    has_many :term_relationships, :foreign_key => 'object_id'
    has_many :term_taxonomies, :through => :term_relationships,
             :class_name => 'WordPress::TermTaxonomy'

    def categories
      term_taxonomies.inject([]) do |list, taxonomy|
        if taxonomy.taxonomy.eql?('category')
          list << taxonomy.term.name
        end
        list
      end
    end

    def tags
      term_taxonomies.inject([]) do |list, taxonomy|
        if taxonomy.taxonomy.eql?('post_tag')
          list << taxonomy.term.name
        end
        list
      end
    end

    def comments
      WordPress::Comment.find_all_by_comment_post_ID(self.ID)
    end
  end
end