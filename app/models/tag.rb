class Tag < ActiveRecord::Base
  has_many :taggings

  class << self
    def [](tag)
      find_by_name(tag.to_s)
    end

    # parses a list of tags into tag names
    #
    #   Tag.parse('a, b, c')
    #   # => ['a', 'b', 'c']
    #
    #   Tag.parse("a b c")
    #   # => ['a', 'b', 'c']
    #
    #   Tag.parse(%(a "b c"))
    #   # => ['a', 'b c']
    def parse(list)
      return list if list.is_a?(Array)
      list.include?(',') ? parse_with_commas(list) : parse_with_spaces(list)
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
  
    private
      def parse_with_commas(list)
        cleanup_tags(list.split(','))
      end
      
      def parse_with_spaces(list)
        tags = []

        # first, pull out the quoted tags
        list.gsub!(/\"(.*?)\"\s*/ ) { tags << $1; "" }
        
        # then, get whatever's left
        tags.concat list.split(/\s/)

        cleanup_tags(tags)
      end
    
      def cleanup_tags(tags)
        tags.tap do |t|
          t.collect! do |tag|
            unless tag.blank?
              tag.downcase!
              tag.gsub!(/:/, '')
              tag.strip!
              tag
            end
          end
          t.compact!
          t.uniq!
        end
      end
  end

  def ==(comparison_object)
    super || name == comparison_object.to_s
  end

  def to_s()     name end
  alias to_param  to_s
  alias to_liquid to_s
end
