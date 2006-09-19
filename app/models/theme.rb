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
    @name ||= @path.basename.to_s
  end

  def attachments
    return @attachments unless @attachments.nil?
    @attachments, @templates, @resources = Attachments.new, Templates.new, Resources.new
    [@attachments, @templates, @resources].each { |a| a.theme = self }
    Pathname.glob(File.join(base_path, '**/*')).each do |path|
      next unless path.file?
      @attachments << path
      (path.extname == '.liquid' ? @templates : @resources) << path
    end
    @attachments
  end

  [:resources, :templates].each do |attr|
    define_method attr do
      attachments && instance_variable_get("@#{attr}")
    end
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