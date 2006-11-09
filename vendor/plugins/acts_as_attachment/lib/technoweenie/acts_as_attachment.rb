module Technoweenie # :nodoc:
  module ActsAsAttachment # :nodoc:
    @@content_types = ['image/jpeg', 'image/pjpeg', 'image/gif', 'image/png', 'image/x-png']
    mattr_reader :content_types

    class ThumbnailError < StandardError;  end
    class AttachmentError < StandardError; end

    def self.included(base) # :nodoc:
      base.extend ActMethods
    end
    
    module ActMethods
      # Options: 
      #   <tt>:content_type</tt> - Allowed content types.  Allows all by default.  Use :image to allow all standard image types.
      #   <tt>:min_size</tt> - Minimum size allowed.  1 byte is the default.
      #   <tt>:max_size</tt> - Maximum size allowed.  1.megabyte is the default.
      #   <tt>:size</tt> - Range of sizes allowed.  (1..1.megabyte) is the default.  This overrides the :min_size and :max_size options.
      #   <tt>:resize_to</tt> - Used by RMagick to resize images.  Pass either an array of width/height, or a geometry string.
      #   <tt>:thumbnails</tt> - Specifies a set of thumbnails to generate.  This accepts a hash of filename suffixes and RMagick resizing options.
      #   <tt>:thumbnail_class</tt> - Set what class to use for thumbnails.  This attachment class is used by default.
      #   <tt>:file_system_path</tt> - path to store the uploaded files.  Uses public/#{table_name} by default.  
      #                                Setting this sets the :storage to :file_system.
      #   <tt>:storage</tt> - Use :file_system to specify the attachment data is stored with the file system.  Defaults to :db_system.
      #
      # Examples:
      #   acts_as_attachment :max_size => 1.kilobyte
      #   acts_as_attachment :size => 1.megabyte..2.megabytes
      #   acts_as_attachment :content_type => 'application/pdf'
      #   acts_as_attachment :content_type => ['application/pdf', 'application/msword', 'text/plain']
      #   acts_as_attachment :content_type => :image, :resize_to => [50,50]
      #   acts_as_attachment :content_type => ['application/pdf', :image], :resize_to => 'x50'
      #   acts_as_attachment :thumbnails => { :thumb => [50, 50], :geometry => 'x50' }
      #   acts_as_attachment :storage => :file_system, :file_system_path => 'public/files'
      #   acts_as_attachment :storage => :file_system, :file_system_path => 'public/files', 
      #     :content_type => :image, :resize_to => [50,50]
      #   acts_as_attachment :storage => :file_system, :file_system_path => 'public/files',
      #     :thumbnails => { :thumb => [50, 50], :geometry => 'x50' }
      def acts_as_attachment(options = {})
        # this allows you to redefine the acts' options for each subclass, however
        set_fs_path = options.keys.include? :file_system_path
        options[:thumbnails]       ||= {}
        options[:thumbnail_class]  ||= self
        options[:min_size]         ||= 1
        options[:max_size]         ||= 1.megabyte
        options[:size]             ||= (options[:min_size]..options[:max_size])
        options[:file_system_path] ||= File.join("public", table_name)
        options[:file_system_path]   = options[:file_system_path][1..-1] if options[:file_system_path].first == '/'

        # only need to define these once on a class
        unless included_modules.include? InstanceMethods
          class_inheritable_accessor :attachment_options, :attachment_attributes

          # so far, parent_id is the only attribute i care about checking
          self.attachment_attributes = [:parent_id].inject({}) { |memo, attr_name| memo.update attr_name => column_names.include?(attr_name.to_s) }

          after_destroy :destroy_file

          before_validation     :sanitize_filename
          with_options :foreign_key => 'parent_id' do |m|
            m.has_many   :thumbnails, :dependent => :destroy, :class_name => options[:thumbnail_class].to_s
            m.belongs_to :parent, :class_name => self.base_class.to_s
          end if attachment_attributes[:parent_id]

          include set_fs_path || options[:storage] == :file_system ? FileSystemMethods : DbFileMethods
          
          if included_modules.include?(DbFileMethods) && !column_names.include?('db_file_id')
            raise AttachmentError.new("Database attachments must have a db_file_id column")
          end
          
          after_save :create_attachment_thumbnails # allows thumbnails with parent_id to be created

          extend  ClassMethods
          include InstanceMethods
        end
        
        options[:content_type] = [options[:content_type]].flatten.collect { |t| t == :image ? Technoweenie::ActsAsAttachment.content_types : t }.flatten unless options[:content_type].nil?
        self.attachment_options = options
      end
    end
  end
end
