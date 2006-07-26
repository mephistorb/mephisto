class Section < ActiveRecord::Base
  ARTICLES_COUNT_SQL = 'INNER JOIN assigned_sections ON contents.id = assigned_sections.article_id INNER JOIN sections ON sections.id = assigned_sections.section_id' unless defined?(ARTICLES_COUNT)
  validates_presence_of :name
  before_create :create_path
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
    
    # given a section name like ['about', 'site_map'], about is the section and site_map is a left over page_name
    # returns [<#Section: about>, 'site_map']
    def find_section_and_page_name(section_path)
      page_name = []
      section   = nil
      while section.nil? && section_path.any?
        section    = find_by_path(section_path.join('/'))
        page_name << section_path.pop if section.nil?
      end
      [section, page_name.any? ? page_name.join('/') : nil]
    end

    def articles_count
      Article.count :all, :group => :section_id, :joins => ARTICLES_COUNT_SQL
    end
  end

  def to_liquid
    Mephisto::Liquid::SectionDrop.new self
  end

  def order!(*article_ids)
    transaction do
      article_ids.flatten.each_with_index do |article, pos|
        assigned_sections.detect { |s| s.article_id.to_s == article.to_s }.update_attributes(:position => pos)
      end
      save
    end
  end

  def articles_count
    @articles_count ||= Article.count :all, :joins => ARTICLES_COUNT_SQL
  end

  def hash_for_url(options = {})
    { :sections => to_url }.merge(options)
  end

  def home?
    name == 'home'
  end

  def to_url
    ((name.nil? || home?) ? '' : name).split('/')
  end

  def to_feed_url
    to_url << 'atom.xml'
  end
  
  protected
    def create_path
      # nasty regex because i want to keep alpha numerics AND /'s
      self.path = name.to_s.gsub(/[^\w\/]|[!\(\)\.]+/, ' ').strip.downcase.gsub(/\ +/, '-') if path.blank?
    end
end
