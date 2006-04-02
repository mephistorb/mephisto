module Technoweenie # :nodoc:
  module ActsAsAttachment # :nodoc:
    @@content_types = ['image/jpeg', 'image/pjpeg', 'image/gif', 'image/png', 'image/x-png']
    mattr_reader :content_types

    def self.included(base) # :nodoc:
      base.extend ActMethods
    end
    
    module ActMethods # :nodoc:
      def self.content_types
        Technoweenie::ActsAsAttachment.content_types
      end

      # Options: 
      #   <tt>:content_type</tt> - Allowed content types.  Allows all by default.  Use :image to allow all standard image types.
      #   <tt>:min_size</tt> - Minimum size allowed.  1 byte is the default.
      #   <tt>:max_size</tt> - Maximum size allowed.  1.megabyte is the default.
      #   <tt>:size</tt> - Range of sizes allowed.  (1..1.megabyte) is the default.  This overrides the :min_size and :max_size options.
      #   <tt>:resize_to</tt> - Used by RMagick to resize images.  Pass either an array of width/height, or a geometry string.
      #   <tt>:thumbnails</tt> - Specifies a set of thumbnails to generate.  This accepts a hash of filename suffixes and RMagick resizing options.
      #   <tt>:file_system_path</tt> - path to store the uploaded files.  Uses public/#{table_name} by default.
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
        # only need to define these once on a class
        unless included_modules.include? InstanceMethods
          class_inheritable_accessor :attachment_options

          before_save   :prepare_storage
          after_save    :save_to_storage
          after_create  :create_attachment_thumbnails
          after_destroy :destroy_file

          validates_presence_of :size, :content_type, :filename
          validate              :attachment_attributes_valid?

          send :extend,  ClassMethods
          send :include, InstanceMethods
        end

        with_options :class_name => self.to_s, :foreign_key => 'parent_id' do |m|
          m.has_many   :thumbnails, :dependent => :destroy
          m.belongs_to :parent
        end

        # this allows you to redefine the acts' options for each subclass, however
        options[:thumbnails]       ||= {}
        options[:min_size]         ||= 1
        options[:max_size]         ||= 1.megabyte
        options[:size]             ||= (options[:min_size]..options[:max_size])
        options[:file_system_path] ||= File.join("public", table_name)
        options[:file_system_path]   = options[:file_system_path][1..-1] if options[:file_system_path][0..0] == '/'
        options[:content_type]       = [options[:content_type]].flatten.collect { |t| t == :image ? content_types : t }.flatten unless options[:content_type].nil?
        
        include options[:storage] == :file_system ? FileSystemMethods : DbFileMethods
        self.attachment_options = options
      end
    end

    module ClassMethods
      def content_types
        Technoweenie::ActsAsAttachment.content_types
      end

      def image?(content_type)
        content_types.include?(content_type)
      end

      def with_image(binary_data, &block)
        binary_data = Magick::Image::from_blob(binary_data).first unless binary_data.is_a?(Magick::Image)
        block.call binary_data if block and binary_data
      rescue 
        # Log the failure to load the image.  This should match ::Magick::ImageMagickError
        # but that would cause acts_as_attachment to require rmagick.
        logger.debug("Exception working with image: #{$!}")
        binary_data = nil
      ensure
        not binary_data.nil? # return true if it was a valid image
      end
    end

    module InstanceMethods
      # Checks whether the attachment's content type is an image content type
      def image?
        self.class.image?(content_type.to_s.strip)
      end
      
      def build_thumbnail(file_name_suffix, *size)
        basename, ext = filename.split '.'
        #TODO: should the store_in_fs field be mandatory so we don't have to do this
        thumbnails.build \
          :content_type    => content_type, 
          :filename        => "#{basename}_#{file_name_suffix}.#{ext}", 
          :attachment_data => resize_image_to(size)
      end
      
      def create_thumbnail(file_name_suffix, *size)
        thumb = build_thumbnail file_name_suffix, *size
        thumb.save
        thumb
      end

      def uploaded_data=(file_data)
        return nil if file_data.nil? or file_data.size == 0 
        self.content_type    = file_data.content_type.strip
        self.filename        = sanitize_filename(file_data.original_filename) if filename.blank?
        self.attachment_data = file_data.read
      end

      def aspect_ratio
        image? ? width.to_f / height.to_f : 0
      end

      def attachment_data=(data)
        if data.nil?
          @attachment_data = nil
          @save_attachment = false
          return nil
        end
        with_image data do |img|
          resized_img = attachment_options[:resize_to] ? thumbnail_for_image(img, attachment_options[:resize_to]) : img
          data        = resized_img.to_blob
          self.width  = resized_img.columns
          self.height = resized_img.rows
        end if image?
        self.size = data.length
        @save_attachment = true
        @attachment_data = data
      end

      def resize_image_to(size)
        thumb_img = nil
        with_image do |img|
          thumb_img = thumbnail_for_image(img, size)
        end
        thumb_img
      end

      # Allows you to work with an RMagick representation of the attachment in a block.  
      #
      #   @attachment.with_image do |img|
      #     self.data = img.thumbnail(100, 100).to_blob
      #   end
      #
      def with_image(data = self.attachment_data, &block)
        self.class.with_image(data, &block)
      end

      protected
      def thumbnail_for_image(img, size)
        size = size.first if size.is_a?(Array) and size.length == 1 and not size.first.is_a?(Fixnum)
        if size.is_a?(Fixnum) or (size.is_a?(Array) and size.first.is_a?(Fixnum))
          size = [size, size] if size.is_a?(Fixnum)
          img.thumbnail(size.first, size[1])
        else
          img.change_geometry(size.to_s) { |cols, rows, image| image.resize(cols, rows) }
        end
      end

      def sanitize_filename(filename)
        return unless filename
        # NOTE: File.basename doesn't work right with Windows paths on Unix
        # get only the filename, not the whole path
        filename.gsub! /^.*(\\|\/)/, ''

        # Finally, replace all non alphanumeric, underscore or periods with underscore
        filename.gsub /[^\w\.\-]/, '_'
      end
      
      # creates default thumbnails for parent attachments
      # XXX (streadway) shouldn't this be done every time the attachment_data is updated?
      def create_attachment_thumbnails
        attachment_options[:thumbnails].each { |suffix, size| create_thumbnail(suffix, size) } unless parent_id
      end

      # validates the size and content_type attributes according to the current model's options
      def attachment_attributes_valid?
        [:size, :content_type].each do |attr_name|
          enum = attachment_options[attr_name]
          errors.add attr_name, ActiveRecord::Errors.default_error_messages[:inclusion] unless enum.nil? or enum.include?(send(attr_name))
        end
      end
    end
        
    module DbFileMethods
      def self.included(base) #:nodoc:
        base.belongs_to :db_file
        
        def attachment_data
          @attachment_data ||= db_file.data
        end
      end

      protected
      def destroy_file
        db_file.destroy if db_file
      end

      def prepare_storage
        build_db_file unless self.db_file
        true
      end
      
      def save_to_storage
        self.db_file.update_attributes(:data => attachment_data) if @save_attachment
        @save_attachment = nil
        true
      end
    end
    
    module FileSystemMethods
      def attachment_data
        @attachment_data ||= File.read(full_filename)
      end

      def full_filename
        File.expand_path(File.join(RAILS_ROOT, attachment_options[:file_system_path], id.to_s, filename))
      end

      protected
      def destroy_file
        FileUtils.rm full_filename
      end
      
      def prepare_storage
        true
      end
      
      def save_to_storage
        if @save_attachment
          # TODO: This overwrites the file if it exists, maybe have an allow_overwrite option?
          FileUtils.mkdir_p(File.dirname(full_filename))
          
          # TODO Convert to streaming storage to prevent excessive memory usage
          # FileUtils.copy_stream is very efficient in regards to copies
          File.open(full_filename, "w") do |file|
            file.write(attachment_data)
          end
        end
        @save_attachment = nil
        true
      end
    end
  end
end
