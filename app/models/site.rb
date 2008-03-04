require 'uri'

class Site < ActiveRecord::Base
  @@default_assigns = {}
  @@theme_path      = Pathname.new(RAILS_ROOT) + 'themes'
  cattr_reader :theme_path, :default_assigns

  cattr_accessor :multi_sites_enabled, :cache_sweeper_tracing
  
  # @@template_handlers = HashWithIndifferentAccess.new if @@template_handlers.nil?
  @@template_handlers = {}
  
  # Register a class that knows how to handle template files with the given
  # extension. This can be used to implement new template types.
  # The constructor for the class must take a Site instance
  # as a parameter, and the class must implement a #render method that
  # has the following signature
  # def render(section, layout, template, assigns ={}, controller = nil)
  # and return the rendered template as a string.
  def self.register_template_handler(extension, klass)
    @@template_handlers[extension] = klass
  end
  register_template_handler(".liquid", Mephisto::Liquid::LiquidTemplate)

  def self.extensions
    @@template_handlers.keys
  end

  @@spam_detection_engines = []
  def self.register_spam_detection_engine(name, klass)
    @@spam_detection_engines<< [name, klass.name]
  end
  cattr_reader :spam_detection_engines

  has_many  :sections, :order => "position", :dependent => :destroy do
    def home
      find_by_path ''
    end

    # orders sections in a site
    def order!(*sorted_ids)
      transaction do
        sorted_ids.flatten.each_with_index do |section_id, pos|
          Section.update_all ['position = ?', pos], ['id = ? and site_id = ?', section_id, proxy_owner.id]
        end
      end
    end
  end

  has_many  :articles, :dependent => :destroy do
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
  
  has_many  :comments, :order => 'comments.created_at desc', :dependent => :delete_all
  
  has_many  :events, :dependent => :destroy
  
  has_many  :cached_pages, :dependent => :destroy
  
  has_many  :assets, :order => 'created_at desc', :conditions => 'parent_id is null', :dependent => :destroy

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
  validate :spam_engine_is_valid?
  
  after_create :setup_site_theme_directories
  after_create { |site| site.sections.create(:name => 'Home') }
  before_destroy :flush_cache_and_remove_site_directories    
  before_save :clear_approve_comment_if_spam_engine_not_null

  with_options :order => 'contents.created_at DESC', :class_name => 'Comment' do |comment|
    comment.has_many :comments,            :conditions => ['contents.approved = ?', true]
    comment.has_many :unapproved_comments, :conditions => ['contents.approved = ? or contents.approved is null', false]
    comment.has_many :all_comments
  end
  
  serialize :spam_engine_options, Hash
  def spam_engine_options
    read_attribute(:spam_engine_options) || Hash.new
  end

  def spam_engine
    klass_name = read_attribute(:spam_detection_engine)
    return Mephisto::SpamDetectionEngines::NullEngine.new(self) if klass_name.blank?
    klass_name.constantize.new(self)
  end

  def self.search_by_host_or_title(search_string)
    conditions = search_string.blank? ? nil : ["host LIKE ? OR title LIKE ?"] + ["%#{search_string}%"] * 2
    with_scope( :find => { :conditions => conditions } ) do
      yield
    end
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
    Tag.find(:all, :select      => "DISTINCT tags.name",
                   :joins       => "INNER JOIN taggings ON taggings.tag_id = tags.id INNER JOIN contents ON (taggings.taggable_id = contents.id AND 
                                    taggings.taggable_type = 'Content')",
                   :conditions  => ['contents.type = ? AND contents.site_id = ?', 'Article', id],
                   :order       => 'tags.name')
  end

  def theme_path
    @theme_path ||= self.class.theme_path + "site-#{id}"
  end

  def attachment_path
    theme.path
  end

  def themes
    return @themes unless @themes.nil?
    @themes = []
    FileUtils.mkdir_p theme_path
    Dir.foreach theme_path do |e|
      next if e.first == '.'
      entry = theme_path + e
      next unless entry.directory?
      @themes << Theme.new(entry, self)
    end
    def @themes.[](key) key = key.to_s ; detect { |t| t.name == key } ; end
    @themes.sort! {|a,b| a.name <=> b.name}
  end

  def theme
    @theme ||= themes[current_theme_path] || themes.first || raise(MissingThemesError.new(self))
  end

  def change_theme_to(new_theme_path)
    new_theme = (new_theme_path.is_a?(Theme) ? new_theme_path : themes[new_theme_path]) || raise("No theme '#{new_theme_path}' found")
    update_attribute :current_theme_path, new_theme.path.basename.to_s
    @theme = nil
    theme
  end

  def import_theme(zip_file, name)
    imported_name = Theme.import zip_file, :to => theme_path + name
    @theme = @themes = @rollback_theme = nil
    themes[imported_name]
  end

  def move_theme(theme, new_name)
    FileUtils.move theme.base_path, theme_path + new_name
  end

  [:attachments, :templates, :resources].each { |m| delegate m, :to => :theme }

  def permalink_for(article)
    Mephisto::Dispatcher.build_permalink_with(permalink_style, article)
  end

  def search_url(query, page = nil)
    "/#{search_path}?q=#{CGI::escapeHTML(query)}#{%(&amp;page=#{CGI::escapeHTML(page.to_s)}) unless page.blank?}"
  end

  def tag_url(*tags)
    ['', tag_path, *tags.collect { |t| URI::escape(t.to_s) }] * '/' 
  end

  def accept_comments?
    comment_age.to_i > -1
  end

  def call_render(section, template_type, assigns = {}, controller = nil)
    assigns.update('site' => to_liquid(section), 'mode' => template_type)
    assigns.update(default_assigns) unless default_assigns.empty?
    template = set_content_template(section, template_type)
    layout = set_layout_template(section, template_type)
    handler = @@template_handlers[theme.extension] || @@template_handlers[".liquid"]
    handler.new(self).render(section, layout, template, assigns, controller)
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

  def page_cache_directory
    multi_sites_enabled ? 
      (RAILS_PATH + (RAILS_ENV == 'test' ? 'tmp' : 'public') + 'cache' + host) :
      (RAILS_PATH + (RAILS_ENV == 'test' ? 'tmp/cache' : 'public'))
  end

  def expire_cached_pages(controller, log_message, pages = nil)
    controller = controller.class unless controller.is_a?(Class)
    pages ||= cached_pages.find_current(:all)
    returning cached_log_message_for(log_message, pages) do |msg|
      controller.logger.warn msg if cache_sweeper_tracing
      pages.each { |p| controller.expire_page(p.url) }
      CachedPage.expire_pages(self, pages)
    end
  end

#need non protected method for ErbTemplate - psq
  def find_preferred_template(template_type, custom_template)
    preferred = templates.find_preferred(template_type, custom_template)
    return preferred if preferred && preferred.file?
    raise MissingTemplateError.new(template_type, templates.collect_templates(template_type, custom_template).collect(&:basename))
  end

  protected
    # If we aren't using the null engine, comments must not be approved automatically.
    def clear_approve_comment_if_spam_engine_not_null
      returning true do
        if self.spam_engine.null?
          # NOP, leave as-is
        else
          self.approve_comments = false 
        end
      end
    end

    # A validation filter.
    def spam_engine_is_valid?
      logger.debug {"==> self.spam_engine.valid_key? #{self.spam_engine.valid_key?}"}
      return if self.spam_engine.valid_key?
      if errors = self.spam_engine.errors then
        errors.each do |error|
          self.errors.add_to_base(error)
        end
      else
        logger.debug {"==> No errors were logged, add something minimal"}
        self.errors.add_to_base("Failed to validate the spam engine's key")
      end
    end

    def cached_log_message_for(log_message, pages)
      pages.inject([log_message, "Expiring #{pages.size} page(s)"]) { |msg, p| msg << " - #{p.url}" }.join("\n")
    end
  
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
    
    def set_content_template(section, template_type)
      preferred_template = 
        case template_type
          when :page, :section
            template_type = :single if template_type == :page
            section.template
          when :archive
            section.archive_template
        end
      find_preferred_template(template_type, preferred_template)
    end
    
    def set_layout_template(section, template_type)
      layout_template =
        if section
          section.layout
        else
          case template_type
            when :tag    then tag_layout
            when :search then sections.detect(&:home?).layout
          end
        end
      find_preferred_template(:layout, layout_template)
    end

    private
    
    def setup_site_theme_directories
      begin
        theme_path = "#{RAILS_ROOT}/themes/site-#{self.id}/simpla"
        FileUtils.mkdir_p("#{RAILS_ROOT}/themes/site-#{self.id}")
        FileUtils.cp_r("#{RAILS_ROOT}/themes/default", theme_path)
        Dir[File.join(theme_path, '**/.svn')].each do |dir|
          FileUtils.rm_rf dir
        end
      rescue
        logger.error "ERROR: removing directories for site #{self.host}, check file permissions."
        errors.add_to_base "Unable to create theme directories."
        false
      end
    end

    def flush_cache_and_remove_site_directories
      begin
        CachedPage.expire_pages self, self.cached_pages
        FileUtils.rm_rf("#{RAILS_ROOT}/themes/site-#{self.id}")
        FileUtils.rm_rf("#{RAILS_ROOT}/public/cache/#{self.host}")
      rescue
        logger.error "ERROR: removing directories for site #{self.host}, check file permissions."
        false
      end
    end

end
