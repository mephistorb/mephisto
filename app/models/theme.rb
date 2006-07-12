module Theme
  def find_theme_files(options = {})
    find(:all, {:conditions => ['attachments.type in (?)', %w(Resource Template)], :order => 'attachments.filename'}.merge(options))
  end

  def export_as_zip(name, options = {})
    path = options[:to] || '.'
    Zip::ZipFile.open(File.join(path, "#{name}.zip"), Zip::ZipFile::CREATE) do |zip|
      %w(templates layouts javascripts stylesheets images).each { |d| zip.dir.mkdir(d) }
      write_files_with zip.file
    end
  end

  def export(name, options = {})
    path = File.join(options[:to] || '.', name)
    %w(templates layouts javascripts stylesheets images).each { |d| FileUtils.mkdir_p File.join(path, d) }
    write_files_with File, path
  end

  private
    def write_files_with(file_object, path = '')
      find_theme_files.each do |file|
        file_object.open(File.join(path, file.path, file.is_a?(Template) ? file.filename + '.liquid' : file.filename), 'w') { |f| f.write file.attachment_data }
      end
    end
end