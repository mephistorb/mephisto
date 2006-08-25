class Site < ActiveRecord::Base
  include Mephisto::Attachments::AttachmentMethods
  cattr_accessor :multi_sites_enabled

  has_many  :sections do
    def home
      Section.find_by_path 'home'
    end
  end

  has_many  :articles
  has_many  :events
  
  has_many  :assets, :as => :attachable, :order => 'created_at desc'
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

  def render_liquid_for(section, template_type, assigns = {}, controller = nil)
    template_type       = set_template_type_for  section, template_type
    assigns['site']     = to_liquid(section)
    assigns['content_for_layout'] = parse_template(set_preferred_template(section, template_type), assigns, controller)
    parse_template(set_layout_template(section, template_type), assigns, controller)
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
    
    def set_template_type_for(section, template_type)
      template_type == :section && section.show_paged_articles? ? :page : template_type
    end
    
    def set_preferred_template(section, template_type)
      preferred_template = section.template if [:page, :section].include?(template_type)
      preferred_template.blank? ? templates.find_preferred(template_type) : templates[preferred_template]
    end
    
    def set_layout_template(section, template_type)
      layout_template = section && section.layout
      templates[layout_template.blank? ? 'layout' : layout_template]
    end
    
    def parse_template(template, assigns, controller)
      Liquid::Template.parse((template && template.file? && template.read).to_s).render(assigns, :registers => {:controller => controller})
    end
end
