class Site < ActiveRecord::Base
  has_many  :sections
  has_many  :articles
  has_many  :drafts, :class_name => 'Article::Draft'
  
  has_many  :assets, :as => :attachable
  has_many  :templates
  has_many  :resources
  has_many  :attachments, :extend => Theme
  
  serialize :filters, Array
  
  validates_uniqueness_of :host

  def filters=(value)
    write_attribute :filters, [value].flatten.collect(&:to_sym)
  end

  def to_liquid
    {
      'title'    => title, 
      'subtitle' => subtitle,
      'host'     => host
    }
  end
end
