class Tagging < ActiveRecord::Base
  belongs_to :tag
  belongs_to :taggable, :polymorphic => true

  class << self
    # Sets the tags on the taggable object.  Only adds new tags and deletes old tags.
    #
    #   Tagging.set_on taggable, 'foo, bar'
    def set_on(taggable, tag_list)
      current_tags  = taggable.tags
      new_tags      = Tag.parse_to_tags(tag_list)
      delete_from taggable, (current_tags - new_tags)
      add_to      taggable, new_tags
    end
    
    # Deletes tags from the taggable object
    #
    #   Tagging.delete_from taggable, [1, 2, 3]
    #   Tagging.delete_from taggable, [Tag, Tag, Tag]
    def delete_from(taggable, tags)
      delete_all ['taggable_id = ? and taggable_type = ? and tag_id in (?)', 
        taggable.id, taggable.class.base_class.name, tags.collect { |t| t.is_a?(Tag) ? t.id : t }] if tags.any?
    end

    # Adds tags to the taggable object
    #
    #   Tagging.add_to taggable, [Tag, Tag, Tag]
    def add_to(taggable, tags)
      (tags - taggable.tags).each do |tag|
        create! :taggable => taggable, :tag => tag
      end unless tags.empty?
    end
  end
end
