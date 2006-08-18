module Mephisto
  module TaggableMethods
    def self.included(base)
      base.has_many :taggings, :as => :taggable
      base.has_many :tags, :through => :taggings, :order => 'tags.name'
    end
    
    def tag=(tag_list)
      Tagging.set_on self, tag_list
    end
    
    def tag
      tags.collect(&:name) * ', '
    end
  end
end