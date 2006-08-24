module Mephisto
  module TaggableMethods
    def self.included(base)
      base.has_many :taggings, :as => :taggable, :class_name => '::Tagging'
      base.has_many :tags, :through => :taggings, :order => 'tags.name', :class_name => '::Tag'
      base.after_save :save_tags
      base.send :attr_writer, :tag
      base.extend ClassMethods
    end
    
    def tag
      @tag ||= tags.collect(&:name) * ', '
    end
    
    protected
      def save_tags
        Tagging.set_on self, @tag if @tag
        @tag = nil
      end
      
    module ClassMethods
      def find_tagged_with(list)
        find :all, :select => "#{table_name}.*", :from => "#{table_name}, tags, taggings",
          :conditions => ["#{table_name}.#{primary_key} = taggings.taggable_id 
            and taggings.taggable_type = ?
            and taggings.tag_id = tags.id and tags.name IN (?)", name, Tag.parse(list)]
      end
    end
  end
end