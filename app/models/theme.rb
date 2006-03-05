class Theme
  class << self
    def find_current(options = {})
      Attachment.find(:all, {:conditions => ['attachments.type in (?)', %w(Resource Template LayoutTemplate)], :order => 'attachments.filename'}.merge(options))
    end

    def export(name, options = {})
      path = File.join(options[:to] || '.', name)
      %w(templates layouts javascripts stylesheets images).each { |d| FileUtils.mkdir_p File.join(path, d) }
      find_current.each do |file|
        filename = case file
          when Resource       then file.full_path
          when LayoutTemplate then File.join('layouts', file.filename + '.liquid')
          when Template       then File.join('templates', file.filename + '.liquid')
        end
        File.open(File.join(path, filename), 'w') { |f| f.write file.data }
      end
    end
  end
end