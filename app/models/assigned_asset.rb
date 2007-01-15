class AssignedAsset < ActiveRecord::Base
  belongs_to :article, :counter_cache => 'assets_count'
  belongs_to :asset
  acts_as_list :scope => :article_id
  validates_presence_of :article_id, :asset_id
  validate_on_create :check_for_dupe_article_and_asset

  protected
    def check_for_dupe_article_and_asset
      unless self.class.count(:all, :conditions => ['article_id = ? and asset_id = ?', article_id, asset_id]).zero?
        errors.add_to_base("Cannot have a duplicate assignment for this article and asset")
      end
    end
end
