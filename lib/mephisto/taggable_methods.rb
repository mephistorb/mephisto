module Mephisto
  module TaggableMethods
    def self.included(base)
      base.has_many :taggings, :as => :taggable
      base.has_many :tags, :through => :taggings, :order => 'tags.name'
      base.after_save :save_tags
      base.send :attr_writer, :tag
    end
    
    def tag
      @tag ||= tags.collect(&:name) * ', '
    end
    
    protected
      def save_tags
        Tagging.set_on self, @tag if @tag
        @tag = nil
      end
  end
end