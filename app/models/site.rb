class Site < ActiveRecord::Base
  PERMALINK_OPTIONS = { 'year' => '\d{4}', 'month' => '\d{1,2}', 'day' => '\d{1,2}', 'permalink' => '[a-z0-9-]+', 'id' => '\d+' }
  PERMALINK_VAR     = /^:([a-z]+)$/

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
      
      find :first, :conditions => conditions, :order => 'published_at desc'
    end
  end
  
  has_many  :comments, :order => 'comments.created_at desc'
  
  has_many  :events
  
  has_many  :cached_pages
  
  has_many  :assets, :as => :attachable, :order => 'created_at desc'
  has_many  :assets, :order => 'created_at desc', :conditions => 'parent_id is null'

  has_many :memberships, :dependent => :destroy
  has_many :members, :through => :memberships, :source => :user
  has_many :admins,  :through => :memberships, :source => :user, :conditions => ['memberships.admin = ? or users.admin = ?', true, true]

  before_validation :downcase_host
  before_validation :set_default_attributes
  validates_presence_of :permalink_style, :search_path, :tag_path
  validates_format_of     :search_path, :tag_path, :with => Format::STRING
  validates_format_of     :host, :with => Format::DOMAIN
  validates_uniqueness_of :host
  validate :check_permalink_style
  after_create { |s| s.sections.create(:name => 'Home', :path => '') }
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

  def user_by_token(token)
    User.find_by_token(self, token)
  end
  
  def user_by_email(email)
    User.find_by_email(self, email)
  end

  def tags
    Tag.find(:all, :conditions => ['contents.type = ? AND contents.site_id = ?', 'Article', id], :order => 'tags.name',
      :joins => "INNER JOIN taggings ON taggings.tag_id = tags.id INNER JOIN contents ON (taggings.taggable_id = contents.id AND taggings.taggable_type = 'Content')")
  end

  def permalink_regex(refresh = false)
    if refresh || @permalink_regex.nil?
      @permalink_variables = []
      r = permalink_style.split('/').inject [] do |s, piece|
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
    old_published = article.published_at
    article.published_at ||= Time.now.utc
    permalink_style.split('/').inject [''] do |s, piece|
      s << (piece =~ PERMALINK_VAR && PERMALINK_OPTIONS.keys.include?($1) ? article.send($1).to_s : piece)
    end.join('/')
  ensure
    article.published_at = old_published
  end

  def search_url(query, page = nil)
    "/#{search_path}?q=#{CGI::escapeHTML(query)}#{%(&page=#{CGI::escapeHTML(page.to_s)}) unless page.blank?}"
  end

  def tag_url(*tags)
    ['', tag_path, *tags] * '/'
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
    SiteDrop.new self, current_section
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

    def check_permalink_style
      permalink_style.sub! /^\//, ''
      permalink_style.sub! /\/$/, ''
      pieces = permalink_style.split('/')
      errors.add :permalink_style, 'cannot have blank paths' if pieces.any?(&:blank?)
      pieces.each do |p|
        errors.add :permalink_style, "cannot contain '#{$1}' variable" if p =~ PERMALINK_VAR && !PERMALINK_OPTIONS.keys.include?($1)
      end
      unless pieces.include?(':id') || pieces.include?(':permalink')
        errors.add :permalink_style, "must contain either :permalink or :id"
      end
      if !pieces.include?(':year') && (pieces.include?(':month') || pieces.include?(':day'))
        errors.add :permalink_style, "must contain :year for any date-based permalinks"
      end
    end

    def downcase_host
      self.host = host.to_s.downcase
    end

    def set_default_attributes
      self.permalink_style = ':year/:month/:day/:permalink' if permalink_style.blank?
      self.search_path     = 'search' if search_path.blank?
      self.tag_path        = 'tags'   if tag_path.blank?
      [:permalink_style, :search_path, :tag_path].each { |a| send(a).downcase! }
      self.timezone = 'UTC' if read_attribute(:timezone).blank?
      if new_record?
        self.approve_comments = false unless approve_comments?
        self.comment_age      = 30    unless comment_age
      end
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
      layout_template =
        if section
          section.layout
        else
          case template_type
            when :tag    then tag_layout
            when :search then search_layout
          end
        end

      templates[layout_template.blank? ? 'layout' : layout_template]
    end
    
    def parse_template(template, assigns, controller)
      raise Mephisto::MissingTemplateError, template unless template && template.file?
      # give the include tag access to files in the site's fragments directory
      Liquid::Template.file_system = Liquid::LocalFileSystem.new(File.join(attachment_base_path, 'templates'))
      Liquid::Template.parse(template.read.to_s).render(assigns, :registers => {:controller => controller})
    end
end
