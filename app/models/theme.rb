class Theme
  attr_reader :path, :base_path
  def initialize(base)
    if base.is_a?(Pathname)
      @base_path = base.to_s
      @path      = base
    else
      @base_path = base
      @path      = Pathname.new(@base_path)
    end
  end

  def name
    class << self ; attr_reader :name ; end
    @name = @path.basename.to_s
  end

  def properties
    class << self ; attr_reader :properties ; end
    about = path + 'about.yml'
    @properties = about.exist? ? YAML.load_file(about) : {}
  end

  [:summary, :author, :version, :homepage].each do |attr_name|
    eval <<-END
      def #{attr_name}
        class << self ; attr_reader :#{attr_name} ; end
        @#{attr_name} = properties['#{attr_name}']
      end
    END
  end

  def title
    class << self ; attr_reader :title ; end
    @title = properties['title'] || name
  end

  def linked_author
    class << self ; attr_reader :linked_author ; end
    @linked_author = homepage.blank? ? author : %(<a href="#{CGI.escapeHTML homepage}">#{author}</a>)
  end

  def attachments
    class << self ; attr_reader :attachments ; end
    @attachments, @templates, @resources = Attachments.new, Templates.new, Resources.new
    [@attachments, @templates, @resources].each { |a| a.theme = self }
    Pathname.glob(File.join(base_path, '**/*')).each do |path|
      next unless path.file?
      @attachments << path
      (path.extname == '.liquid' ? @templates : @resources) << path
    end
    @attachments
  end

  def resources
    class << self ; attr_reader :resources ; end
    attachments && instance_variable_get(:@resources)
  end

  def templates
    class << self ; attr_reader :templates ; end
    attachments && instance_variable_get(:@templates)
  end

  def export_as_zip(name, options = {})
    path = options[:to] || '.'
    Zip::ZipFile.open(File.join(path, "#{name}.zip"), Zip::ZipFile::CREATE) do |zip|
      %w(templates layouts javascripts stylesheets images).each { |d| zip.dir.mkdir(d) }
      write_theme_files_with zip.file
    end
  end

  def export(name, options = {})
    path = File.join(options[:to] || '.', name)
    %w(templates layouts javascripts stylesheets images).each { |d| FileUtils.mkdir_p File.join(path, d) }
    write_theme_files_with File, path
  end

  protected
    def write_theme_files_with(file_class, path = '')
      write_mode = file_class.is_a?(Zip::ZipFileSystem::ZipFsFile) ? 'w' : 'wb'
      attachments.each do |full_path| 
        file_class.open((Pathname.new(path) + full_path.relative_path_from(self.path)).to_s, write_mode) { |f| f.write full_path.read }
      end
    end
end