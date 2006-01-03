class Tagging < ActiveRecord::Base
  belongs_to :article
  belongs_to :tag
  acts_as_list :scope => 'tag_id = #{tag_id}'
  validates_presence_of :article_id, :tag_id
  validate_on_create    :check_for_dupe_article_and_tag

  protected
  def check_for_dupe_article_and_tag
    unless self.class.count(['article_id = ? and tag_id = ?', article_id, tag_id]).zero?
      errors.add_to_base("Cannot have a duplicate tagging for this article and tag")
    end
  end
end
