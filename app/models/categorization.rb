class Categorization < ActiveRecord::Base
  belongs_to :article
  belongs_to :category
  acts_as_list :scope => 'category_id = #{category_id}'
  validates_presence_of :article_id, :category_id
  validate_on_create    :check_for_dupe_article_and_category

  protected
  def check_for_dupe_article_and_category
    unless self.class.count(['article_id = ? and category_id = ?', article_id, category_id]).zero?
      errors.add_to_base("Cannot have a duplicate categorization for this article and category")
    end
  end
end
