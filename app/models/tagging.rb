class Tagging < ActiveRecord::Base
  belongs_to :article
  belongs_to :tag
  acts_as_list :scope => 'tag_id = #{tag_id}'
end
