class Site < ActiveRecord::Base
  @@theme_path = Pathname.new(RAILS_ROOT) + 'themes'
  cattr_reader :theme_path

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
  after_create { |s| s.sections.create(:name => 'Home') }

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

  def theme_path
    @theme_path ||= self.class.theme_path + "site-#{id}"
  end

  {:attachment_base => :current, :rollback => :rollback, :other_themes => :other}.each do |key, value|
    define_method "#{key}_path" do
      inst_var = :"@#{key}_path"
      instance_variable_set(inst_var, theme_path + value.to_s) if instance_variable_get(inst_var).nil?
      instance_variable_get(inst_var)
    end
  end

  def attachment_path
    theme.path
  end

  def themes
    return @themes unless @themes.nil?
    @themes = [theme]
    FileUtils.mkdir_p other_themes_path
    Dir.foreach other_themes_path do |e|
      next if e.first == '.'
      entry = other_themes_path + e
      next unless entry.directory?
      @themes << Theme.new(entry)
      @themes.pop if @themes.last.similar_to?(theme)
    end
    def @themes.[](key) key = key.to_s ; detect { |t| t.name == key } ; end
    @themes
  end

  def theme
    return @theme unless @theme.nil?
    @theme = Theme.current(attachment_base_path)
  end

  def rollback_theme
    return @rollback_theme unless @rollback_theme.nil?
    @rollback_theme = Theme.new(rollback_path)
  end

  def change_theme_to(new_theme_path)
    new_theme = (new_theme_path.is_a?(Theme) ? new_theme_path : themes[new_theme_path]) || raise("No theme '#{new_theme_path}' found")
    rollback_path.rmtree if rollback_path.exist?
    if attachment_path.exist?
      FileUtils.cp_r attachment_path, rollback_path
      attachment_path.rmtree
    end
    FileUtils.cp_r new_theme.base_path, attachment_base_path
    @theme = @themes = @rollback_theme = nil
    theme
  end

  def import_theme(zip_file, name)
    imported_name = Theme.import zip_file, :to => other_themes_path + name
    @theme = @themes = @rollback_theme = nil
    themes[imported_name]
  end

  def move_theme(theme, new_name)
    FileUtils.move theme.base_path, other_themes_path + new_name
  end

  [:attachments, :templates, :resources].each { |m| delegate m, :to => :theme }

  def permalink_for(article)
    Mephisto::Dispatcher.build_permalink_with(permalink_style, article)
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
    assigns['content_for_layout'] = parse_template(set_content_template(section, template_type), assigns, controller)
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
    def permalink_variable_format?(var)
      Mephisto::Dispatcher.variable_format?(var)
    end

    def permalink_variable?(var)
      Mephisto::Dispatcher.variable?(var)
    end

    def check_permalink_style
      permalink_style.sub! /^\//, ''
      permalink_style.sub! /\/$/, ''
      pieces = permalink_style.split('/')
      errors.add :permalink_style, 'cannot have blank paths' if pieces.any?(&:blank?)
      pieces.each do |p|
        errors.add :permalink_style, "cannot contain '#{p}' variable" unless p.blank? || permalink_variable_format?(p).nil? || permalink_variable?(p)
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
    
    def set_content_template(section, template_type)
      preferred_template = section.template if [:page, :section].include?(template_type)
      find_preferred_template(template_type, preferred_template)
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
      find_preferred_template(:layout, layout_template)
    end

    def find_preferred_template(template_type, custom_template)
      preferred = templates.find_preferred(template_type, custom_template)
      return preferred if preferred && preferred.file?
      raise MissingTemplateError.new(template_type, templates.collect_templates(template_type, custom_template).collect(&:basename))
    end
    
    def parse_template(template, assigns, controller)
      # give the include tag access to files in the site's fragments directory
      Liquid::Template.file_system = Liquid::LocalFileSystem.new(File.join(attachment_base_path, 'templates'))
      Liquid::Template.parse(template.read.to_s).render(assigns, :registers => {:controller => controller})
    end
end
