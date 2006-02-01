module Typo
  class Article < Content
    has_many :comments, :dependent => true, :order => "created_at ASC", :class_name => 'Typo::Comment'
    has_and_belongs_to_many :tags, :class_name => 'Typo::Tag'
  end
end
