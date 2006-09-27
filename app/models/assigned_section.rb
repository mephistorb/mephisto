class AssignedSection < ActiveRecord::Base
  belongs_to :article
  belongs_to :section, :counter_cache => 'articles_count'
  acts_as_list :scope => 'section_id = #{section_id}'
  validates_presence_of :article_id, :section_id
  validate_on_create    :check_for_dupe_article_and_section

  protected
    def check_for_dupe_article_and_section
      unless self.class.count(:all, :conditions => ['article_id = ? and section_id = ?', article_id, section_id]).zero?
        errors.add_to_base("Cannot have a duplicate categorization for this article and section")
      end
    end
end
