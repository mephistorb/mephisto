class Section < ActiveRecord::Base
  ARTICLES_COUNT_SQL = 'INNER JOIN assigned_sections ON contents.id = assigned_sections.article_id INNER JOIN sections ON sections.id = assigned_sections.section_id'.freeze unless defined?(ARTICLES_COUNT)
  before_validation :set_archive_path
  before_validation_on_create :create_path
  validates_presence_of   :name, :site_id, :archive_path
  validates_format_of     :archive_path, :with => Format::STRING
  validates_exclusion_of  :path, :in => [nil]
  validates_uniqueness_of :path, :case_sensitive => false, :scope => :site_id
  belongs_to :site
  has_many :assigned_sections, :dependent => :delete_all
  has_many :articles, :order => 'position', :through => :assigned_sections do
    def find_by_date(options = {})
      find(:all, { :order => 'contents.published_at desc', 
                   :conditions => ['contents.published_at <= ? AND contents.published_at IS NOT NULL', Time.now.utc] } \
        .merge(options))
    end

    def find_by_position(options = {})
      find(:first, { :conditions => ['contents.published_at <= ? AND contents.published_at IS NOT NULL', Time.now.utc] } \
        .merge(options))
    end

    def find_by_permalink(permalink, options = {})
      find(:first, { :conditions => ['contents.permalink = ? AND published_at <= ? AND contents.published_at IS NOT NULL',
                                      permalink, Time.now.utc] }.merge(options))
    end
  end

  class << self
    # scopes a find operation to return only paged sections
    def find_paged(options = {})
      with_scope :find => { :conditions => ['show_paged_articles = ?', true] } do
        block_given? ? yield : find(:all, options)
      end
    end

    def articles_count
      Article.count :all, :group => :section_id, :joins => ARTICLES_COUNT_SQL
    end
    
    def permalink_for(str)
      str.gsub(/[^\w\/]|[!\(\)\.]+/, ' ').strip.downcase.gsub(/\ +/, '-')
    end
  end

  def to_liquid(current = false)
    SectionDrop.new self, current
  end

  def order!(*article_ids)
    transaction do
      article_ids.flatten.each_with_index do |article, pos|
        assigned_sections.detect { |s| s.article_id.to_s == article.to_s }.update_attributes(:position => pos)
      end
      save
    end
  end

  def hash_for_url(options = {})
    { :path => to_url }.merge(options)
  end

  def home?
    path.blank?
  end

  def to_url
    path.split('/')
  end

  def paged?
    show_paged_articles?
  end
  
  def blog?
    !show_paged_articles?
  end

  def to_page_url(page_name)
    to_url << (page_name.respond_to?(:permalink) ? page_name.permalink : page_name)
  end

  def to_feed_url
    to_page_url 'atom.xml'
  end
  
  protected
    def set_archive_path
      self.archive_path = 'archives' if archive_path.blank?
      archive_path.downcase!
    end

    def create_path
      # nasty regex because i want to keep alpha numerics AND /'s
      self.path = self.class.permalink_for(name.to_s) if path.blank?
    end
end
