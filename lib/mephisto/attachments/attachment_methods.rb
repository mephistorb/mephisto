module Mephisto
  module Attachments
    module AttachmentMethods
      def attachments
        return @attachments unless @attachments.nil?
        @attachments, @templates, @resources = [], [], []
        @attachments.send(:extend, InstanceMethods)
        [@resources, @templates].each { |a| a.send(:extend, BaseMethods); a.site = self }
        @attachments.site = self
        @resources.send(:extend, ResourceMethods)
        @templates.send(:extend, TemplateMethods)
        Pathname.glob(File.join(attachment_base_path, '**/*')).each do |path|
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

      def attachment_path
        @attachment_path ||= Pathname.new(attachment_base_path)
      end

      def attachment_base_path
        @attachment_base_path ||= File.join(RAILS_ROOT, 'themes', "site-#{id}")
      end

      # for @attachments
      module InstanceMethods
        def self.extended(base)
          class << base
            attr_accessor :site
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

        private
          def write_theme_files_with(file_class, path = '')
            write_mode = file_class.is_a?(Zip::ZipFileSystem::ZipFsFile) ? 'w' : 'wb'
            each do |full_path| 
              file_class.open((Pathname.new(path) + full_path.relative_path_from(site.attachment_path)).to_s, write_mode) { |f| f.write full_path.read }
            end
          end
      end

      # shared mixin for @resources and @templates
      module BaseMethods
        def self.extended(base)
          class << base
            attr_accessor :site
          end
        end

        def write(relative_path, data = nil)
          full_path = self[relative_path]
          unless data.nil?
            path, filename = full_path.split
            FileUtils.mkdir_p path.to_s
            File.open(full_path, 'wb') { |f| f.write data }
          end
          full_path
        end
      end
    end
  end
end