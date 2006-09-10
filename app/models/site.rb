class Site < ActiveRecord::Base
  PERMALINK_OPTIONS = { 'year' => '\d{4}', 'month' => '\d{1,2}', 'day' => '\d{1,2}', 'permalink' => '[a-z0-9-]+', 'id' => '\d+' }
  PERMALINK_VAR     = /^:([a-z]+)$/
  @@permalink_slug  = ':year/:month/:day/:permalink'.freeze
  @@archive_slug    = 'archives'.freeze
  @@tag_slug        = 'tags'.freeze
  @@search_slug     = 'search'.freeze

  include Mephisto::Attachments::AttachmentMethods
  cattr_accessor :multi_sites_enabled

  has_many  :sections do
    def home
      find_by_path ''
    end
  end

  has_many  :articles do
    def find_by_permalink(options)
      conditions = 
        returning ["(contents.published_at IS NOT NULL AND contents.published_at <= ?)", Time.now.utc] do |cond|
          if options[:year]
            from, to = Time.delta(options[:year], options[:month], options[:day])
            cond.first << ' AND (contents.published_at BETWEEN ? AND ?)'
            cond << from << to
          end
          
          [:id, :permalink].each do |attr|
            if options[attr]
              cond.first << " AND (contents.#{attr} = ?)"
              cond << options[attr]
            end
          end
        end
      
      find :first, :conditions => conditions
    end
  end
  
  has_many  :events
  
  has_many  :cached_pages
  
  has_many  :assets, :as => :attachable, :order => 'created_at desc'
  has_many  :assets, :order => 'created_at desc', :conditions => 'parent_id is null'

  has_many :memberships
  has_many :members, :through => :memberships, :source => :user
  has_many :admins,  :through => :memberships, :source => :user, :conditions => ['memberships.admin = ? or users.admin = ?', true, true]

  before_validation :downcase_host
  before_validation :set_default_timezone
  before_validation_on_create :set_default_comment_options
  validates_format_of     :host, :with => /^([a-z0-9]([-a-z0-9]*[a-z0-9])?\.)+((a[cdefgilmnoqrstuwxz]|aero|arpa)|(b[abdefghijmnorstvwyz]|biz)|(c[acdfghiklmnorsuvxyz]|cat|com|coop)|d[ejkmoz]|(e[ceghrstu]|edu)|f[ijkmor]|(g[abdefghilmnpqrstuwy]|gov)|h[kmnrtu]|(i[delmnoqrst]|info|int)|(j[emop]|jobs)|k[eghimnprwyz]|l[abcikrstuvy]|(m[acdghklmnopqrstuvwxyz]|mil|mobi|museum)|(n[acefgilopruz]|name|net)|(om|org)|(p[aefghklmnrstwy]|pro)|qa|r[eouw]|s[abcdeghijklmnortvyz]|(t[cdfghjklmnoprtvwz]|travel)|u[agkmsyz]|v[aceginu]|w[fs]|y[etu]|z[amw])$/
  validates_uniqueness_of :host
  validate :check_permalink_slug
  attr_reader :permalink_variables

  with_options :order => 'contents.created_at', :class_name => 'Comment' do |comment|
    comment.has_many :comments,            :conditions => ['contents.approved = ?', true]
    comment.has_many :unapproved_comments, :conditions => ['contents.approved = ? or contents.approved is null', false]
    comment.has_many :all_comments
  end

  def users(options = {})
    User.find_all_by_site self, options
  end
  
  def users_with_deleted(options = {})
    User.find_all_by_site_with_deleted self, options
  end
  
  def user(id)
    User.find_by_site self, id
  end
  
  def user_with_deleted(id)
    User.find_by_site_with_deleted self, id
  end
  
  def tags
    Tag.find(:all, :conditions => ['contents.type = ? AND contents.site_id = ?', 'Article', id], :order => 'tags.name',
      :joins => "INNER JOIN taggings ON taggings.tag_id = tags.id INNER JOIN contents ON (taggings.taggable_id = contents.id AND taggings.taggable_type = 'Content')")
  end
  
  def permalink_slug() @@permalink_slug end
  def archive_slug()   @@archive_slug   end
  def tag_slug()       @@tag_slug       end
  def search_slug()    @@search_slug    end

  def permalink_regex(refresh = false)
    if refresh || @permalink_regex.nil?
      @permalink_variables = []
      r = permalink_slug.split('/').inject [] do |s, piece|
        if piece =~ PERMALINK_VAR
          @permalink_variables << $1.to_sym
          s << "(#{PERMALINK_OPTIONS[$1]})"
        else
          s << piece
        end
      end
      @permalink_regex = Regexp.new("^#{r.join('\/')}(\/comments(\/(\\d+))?)?$")
    end
    
    @permalink_regex
  end

  def permalink_for(article)
    permalink_slug.split('/').inject [''] do |s, piece|
      s << (piece =~ PERMALINK_VAR && PERMALINK_OPTIONS.keys.include?($1) ? article.send($1).to_s : piece)
    end.join('/')
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
    def permalink_variable?(var)
      var =~ PERMALINK_VAR && PERMALINK_OPTIONS.keys.include?(var)
    end

    def check_permalink_slug
      permalink_slug.sub! /^\//, ''
      permalink_slug.sub! /\/$/, ''
      pieces = permalink_slug.split('/')
      errors.add :permalink_slug, 'cannot have blank paths' if pieces.any?(&:blank?)
      pieces.each do |p|
        errors.add :permalink_slug, "cannot contain '#{$1}' variable" if p =~ PERMALINK_VAR && !PERMALINK_OPTIONS.keys.include?($1)
      end
      unless pieces.include?(':id') || pieces.include?(':permalink')
        errors.add :permalink_slug, "must contain either :permalink or :id"
      end
      if !pieces.include?(':year') && (pieces.include?(':month') || pieces.include?(':day'))
        errors.add :permalink_slug, "must contain :year for any date-based permalinks"
      end
    end

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
      # give the include tag access to files in the site's fragments directory
      Liquid::Template.file_system = Liquid::LocalFileSystem.new(File.join(attachment_base_path, 'fragments'))
      Liquid::Template.parse((template && template.file? && template.read).to_s).render(assigns, :registers => {:controller => controller})
    end
end
