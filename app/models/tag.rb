class Tag < ActiveRecord::Base
  has_many :taggings

  class << self
    def [](tag)
      find_by_name(tag.to_s)
    end

    # parses a comma separated list of tags into tag names
    #
    #   Tag.parse('a, b, c')
    #   # => ['a', 'b', 'c']
    def parse(list)
      list.split(',').collect! { |s| s.gsub(/[^\w\ ]+/, '').downcase.strip }.delete_if { |s| s.blank? }
    end
    
    # Parses comma separated tag list and returns tags for them.
    #
    #   Tag.parse_to_tags('a, b, c')
    #   # => [Tag, Tag, Tag]
    def parse_to_tags(list)
      find_or_create(parse(list))
    end
    
    # Returns Tags from an array of tag names
    # 
    #   Tag.find_or_create(['a', 'b', 'c'])
    #   # => [Tag, Tag, Tag]
    def find_or_create(tag_names)
      transaction do
        found_tags = find :all, :conditions => ['name IN (?)', tag_names]
        found_tags + (tag_names - found_tags.collect(&:name)).collect { |s| create!(:name => s) }
      end
    end
  end

  def ==(comparison_object)
    super || name == comparison_object.to_s
  end
  
  def to_s()     name end
  def to_param() name end
end