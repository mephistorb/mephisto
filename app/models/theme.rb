class Theme


  @@root_theme_files   = %w(about.yml preview.png)
  @@theme_directories  = %w(templates layouts javascripts stylesheets images)
  @@allowed_extensions = %w(.js .css .png .gif .jpg .swf .ico) | Site.extensions
  cattr_reader :root_theme_files, :theme_directories, :allowed_extensions
  attr_reader :path, :base_path, :extension

  def self.import(zip_file, options = {})
    dest        = options[:to].is_a?(Pathname) ? options[:to] : Pathname.new(options[:to] || '.')
    basename    = dest.basename.to_s
    if dest.exist? || basename == 'current'
      basename  = basename =~ /(.*)_(\d+)\z/ ? $1 : basename
      number    = $2 ? $2.to_i + 1 : 2
      dirname   = dest.dirname
      dest      = dirname + "#{basename}_#{number}"
      while dest.exist?
        number += 1
        dest    = dirname + "#{basename}_#{number}"
      end
    end
    FileUtils.mkdir_p dest.to_s unless dest.exist?
    Zip::ZipFile.open(zip_file) do |z|
      root_theme_files.each do |file|
        z.file.open(file) { |zf| File.open(dest + file, 'wb') { |f| f << zf.read } } if z.file.exist?(file)
      end
      theme_directories.each do |dir|
        dir_path = Pathname.new(dest + dir)
        FileUtils.mkdir_p dir_path unless dir_path.exist?
        z.dir.entries(dir).each do |entry|
          next unless entry =~ /(\.\w+)\z/ && allowed_extensions.include?($1)
          z.file.open(File.join(dir, entry)) { |zf| File.open(dir_path + entry, 'wb') { |f| f << zf.read } }
        end
      end
    end
    dest.basename.to_s
  rescue
    dest.rmtree if dest.exist?
    raise ThemeError.new(dest, $!.message)
  end

  def initialize(base, site = nil)
    @site = site
    if base.is_a?(Pathname)
      @base_path = base.to_s
      @path      = base
    else
      @base_path = base
      @path      = Pathname.new(@base_path)
    end
    layout = (@path + "layouts").children(false).select {|v| v.to_s =~ /\Alayout/}[0] if (@path + "layouts").directory?
    @extension = layout.extname if layout
  end

  def current?
    @current ||= (@site && @site.current_theme_path == @path.basename.to_s) || :false
    @current != :false
  end

  def name
    class << self ; attr_reader :name ; end
    @name = @path.basename.to_s
  end
  
  alias to_param name

  def preview
    class << self; attr_reader :preview ; end
    @preview = @path + 'preview.png'
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

  def attachments
    class << self ; attr_reader :attachments ; end
    @attachments, @templates, @resources = Attachments.new, Templates.new, Resources.new
    [@attachments, @templates, @resources].each { |a| a.theme = self }
    Pathname.glob(File.join(base_path, '*/*')).each do |path|
      next unless path.file?
      @attachments << path
      ((path.extname == @extension) ? @templates : @resources) << path
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
      theme_directories.each { |d| zip.dir.mkdir(d) }
      write_theme_files_with zip.file
    end
  end

  def export(name, options = {})
    path = File.join(options[:to] || '.', name)
    theme_directories.each { |d| FileUtils.mkdir_p File.join(path, d) }
    write_theme_files_with File, path
  end

  def eql?(comparison_object)
    self == (comparison_object)
  end
  
  def ==(comparison_object)
    base_path == (comparison_object.is_a?(Theme) ? comparison_object.base_path : comparison_object.to_s)
  end

  def similar_to?(theme)
    title == theme.title && version == theme.version
  end

  protected
    def write_theme_files_with(file_class, relative_path = '')
      # ZipFileSystem doesn't support wb
      write_mode = file_class.is_a?(Zip::ZipFileSystem::ZipFsFile) ? 'w' : 'wb'
      relative_path = Pathname.new(relative_path) unless relative_path.is_a?(Pathname)
      root_theme_files.each do |file|
        real_file = path + file
        file_class.open((relative_path + file).to_s, write_mode) { |f| f << real_file.read } if real_file.exist?
      end
      attachments.each do |full_path|
        file_class.open((relative_path + full_path.relative_path_from(path)).to_s, write_mode) { |f| f << full_path.read }
      end
    end
end
