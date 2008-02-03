module WordPress
  class TermTaxonomy < ActiveRecord::Base
    set_table_name 'wp_term_taxonomy'
    set_primary_key 'term_taxonomy_id'
    establish_connection configurations['wp']
        
    has_many :term_relationships, :foreign_key => 'term_taxonomy_id'
    has_many :posts, :through => :term_relationships,
             :class_name => 'WordPress::Post'
    
    def term
      WordPress::Term.find_by_term_id(term_id)
    end
  end
end