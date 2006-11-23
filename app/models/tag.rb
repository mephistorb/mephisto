class Tag < ActiveRecord::Base
  @@tag_parse_regex = /((?: |)['"]{0,1})['"]?\s*(.*?)\s*(?:[,'"]|$)(?:\1(?: |$))/
  has_many :taggings

  class << self
    def [](tag)
      find_by_name(tag.to_s)
    end

    # parses a comma separated list of tags into tag names
    # handles all kinds of different tags. (comma seperated, space seperated (in quotation marks))
    # should handle most the common keyword formats.
    #
    # e.g.: b'log, emacs fun, rails, ruby => "b'log", "emacs fun", "rails", "ruby"
    #       "b'log" "emacs fun" "rails" "ruby" => "b'log", "emacs fun", "rails", "ruby"
    #       'b\'log' 'emacs fun' 'rails' 'ruby' => "b'log", "emacs fun", "rails", "ruby"
    #
    #   Tag.parse('a, b, c')
    #   # => ['a', 'b', 'c']
    def parse(list)
      return list if list.is_a?(Array)
      returning list.scan(@@tag_parse_regex) do |tags|
        tags.collect! { |t| t.last.strip!; t.last }
        tags.uniq!
        tags.delete_if &:blank?
      end
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
  alias to_param  to_s
  alias to_liquid to_s
end
