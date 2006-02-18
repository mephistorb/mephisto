class Section < ActiveRecord::Base
  validates_presence_of :name
  has_many :assigned_sections, :dependent => :delete_all
  has_many :articles, :order => 'assigned_sections.position', :through => :assigned_sections do
    def find_by_date(options = {})
      find(:all, { :order => 'contents.published_at desc', 
                   :conditions => ['published_at <= ? AND contents.published_at IS NOT NULL', Time.now.utc] } \
        .merge(options))
    end

    def find_by_position(options = {})
      find(:first, { :order => 'assigned_sections.position',
                   :conditions => ['published_at <= ? AND contents.published_at IS NOT NULL', Time.now.utc] } \
        .merge(options))
    end

    def find_by_permalink(permalink, options = {})
      find(:first, { :order => 'assigned_sections.position',
                   :conditions => ['contents.permalink = ? AND published_at <= ? AND contents.published_at IS NOT NULL',
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
      section       = nil
      while section.nil? and section_path.any?
        section       = find_by_name(section_path.join('/'))
        page_name << section_path.pop if section.nil?
      end
      [section, page_name.any? ? page_name.join('/') : nil]
    end
  end

  def title
    name.to_s.split('/').last.humanize
  end

  def hash_for_url(options = {})
    { :sections => to_url }.merge(options)
  end

  def to_url
    ((name.nil? or name == 'home') ? '' : name).split('/')
  end
end
