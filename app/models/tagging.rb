class Tagging < ActiveRecord::Base
  belongs_to :article
  belongs_to :tag
  acts_as_list :scope => 'tag_id = #{tag_id}'

  protected
  validates_presence_of :article_id, :tag_id
end
