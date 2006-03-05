class Theme
  class << self
    def find_current(options = {})
      Attachment.find(:all, {:conditions => ['attachments.type in (?)', %w(Resource Template LayoutTemplate)], :order => 'attachments.filename'}.merge(options))
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
      find_current.each do |file|
        filename = case file
          when Resource       then file.full_path
          when LayoutTemplate then File.join('layouts', file.filename + '.liquid')
          when Template       then File.join('templates', file.filename + '.liquid')
        end
        file_object.open(File.join(path, filename), 'w') { |f| f.write file.data }
      end
    end
  end
end