class Site < ActiveRecord::Base
  cattr_accessor :multi_sites_enabled

  has_many  :sections do
    def home
      Section.find_by_path 'home'
    end
  end

  has_many  :articles
  has_many  :events
  
  has_many  :assets, :as => :attachable
  has_many  :templates
  has_many  :resources
  has_many  :attachments, :extend => Theme
  has_many  :assets, :order => 'created_at desc', :conditions => 'parent_id is null'

  before_validation :downcase_host
  before_validation :set_default_timezone
  before_validation_on_create :set_default_comment_options
  validates_format_of     :host, :with => /^([a-z0-9]([-a-z0-9]*[a-z0-9])?\.)+((a[cdefgilmnoqrstuwxz]|aero|arpa)|(b[abdefghijmnorstvwyz]|biz)|(c[acdfghiklmnorsuvxyz]|cat|com|coop)|d[ejkmoz]|(e[ceghrstu]|edu)|f[ijkmor]|(g[abdefghilmnpqrstuwy]|gov)|h[kmnrtu]|(i[delmnoqrst]|info|int)|(j[emop]|jobs)|k[eghimnprwyz]|l[abcikrstuvy]|(m[acdghklmnopqrstuvwxyz]|mil|mobi|museum)|(n[acefgilopruz]|name|net)|(om|org)|(p[aefghklmnrstwy]|pro)|qa|r[eouw]|s[abcdeghijklmnortvyz]|(t[cdfghjklmnoprtvwz]|travel)|u[agkmsyz]|v[aceginu]|w[fs]|y[etu]|z[amw])$/
  validates_uniqueness_of :host

  with_options :order => 'contents.created_at', :class_name => 'Comment' do |comment|
    comment.has_many :comments,            :conditions => ['contents.approved = ?', true]
    comment.has_many :unapproved_comments, :conditions => ['contents.approved = ? or contents.approved is null', false]
    comment.has_many :all_comments
  end

  def accept_comments?
    comment_age.to_i > -1
  end

  def to_liquid(current_section = nil)
    Mephisto::Liquid::SiteDrop.new self, current_section
  end

  composed_of :timezone, :class_name => 'TZInfo::Timezone', :mapping => %w(timezone name)
  alias original_timezone_writer timezone=
  def timezone=(name)
    name = TZInfo::Timezone.new(name) unless name.is_a?(TZInfo::Timezone)
    original_timezone_writer(name)
  end

  protected
    def downcase_host
      self.host = host.to_s.downcase
    end

    def set_default_timezone
      self.timezone = 'UTC' if read_attribute(:timezone).blank?
      true
    end

    def set_default_comment_options
      self.approve_comments = false unless approve_comments?
      self.comment_age      = 30    unless comment_age
      true
    end
end
