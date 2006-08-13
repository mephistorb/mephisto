module Technoweenie # :nodoc:
  module ActsAsAttachment # :nodoc:
    @@content_types = ['image/jpeg', 'image/pjpeg', 'image/gif', 'image/png', 'image/x-png']
    mattr_reader :content_types

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
          class_inheritable_accessor :attachment_options

          after_destroy :destroy_file

          before_validation     :sanitize_filename
          with_options :foreign_key => 'parent_id' do |m|
            m.has_many   :thumbnails, :dependent => :destroy, :class_name => options[:thumbnail_class].to_s
            m.belongs_to :parent, :class_name => self.base_class.to_s
          end

          include set_fs_path || options[:storage] == :file_system ? FileSystemMethods : DbFileMethods
          after_save :create_attachment_thumbnails # allows thumbnails with parent_id to be created

          extend  ClassMethods
          include InstanceMethods
        end
        
        options[:content_type] = [options[:content_type]].flatten.collect { |t| t == :image ? Technoweenie::ActsAsAttachment.content_types : t }.flatten unless options[:content_type].nil?
        self.attachment_options = options
      end
    end

    module ClassMethods
      delegate :content_types, :to => Technoweenie::ActsAsAttachment

      # Performs common validations for attachment models.
      def validates_as_attachment
        validates_presence_of :size, :content_type, :filename
        validate              :attachment_attributes_valid?
      end

      # Returns true or false if the given content type is recognized as an image.
      def image?(content_type)
        content_types.include?(content_type)
      end

      # Yields a block containing an RMagick Image for the given binary data.
      def with_image(binary_data, &block)
        binary_data = Magick::Image::from_blob(binary_data).first unless !Object.const_defined?(:Magick) || binary_data.is_a?(Magick::Image)
        block.call binary_data if block && binary_data
      rescue 
        # Log the failure to load the image.  This should match ::Magick::ImageMagickError
        # but that would cause acts_as_attachment to require rmagick.
        logger.debug("Exception working with image: #{$!}")
        binary_data = nil
      ensure
        !binary_data.nil?
      end

      # Callback after an image has been resized.
      #
      #   class Foo < ActiveRecord::Base
      #     acts_as_attachment
      #     after_resize do |record, img| 
      #       record.aspect_ratio = img.columns.to_f / img.rows.to_f
      #     end
      #   end
      def after_resize(&block)
        write_inheritable_array(:after_resize, [block])
      end

      # Callback after an attachment has been saved either to the file system or the DB.
      # Only called if the file has been changed, not necessarily if the record is updated.
      #
      #   class Foo < ActiveRecord::Base
      #     acts_as_attachment
      #     after_attachment_saved do |record|
      #       ...
      #     end
      #   end
      def after_attachment_saved(&block)
        write_inheritable_array(:after_attachment_saved, [block])
      end

      # Get the thumbnail class, which is the current attachment class by default.
      # Configure this with the :thumbnail_class option.
      def thumbnail_class
        attachment_options[:thumbnail_class] = attachment_options[:thumbnail_class].constantize unless attachment_options[:thumbnail_class].is_a?(Class)
        attachment_options[:thumbnail_class]
      end
    end

    module InstanceMethods
      # Checks whether the attachment's content type is an image content type
      def image?
        self.class.image?(content_type.to_s.strip)
      end

      def thumbnail_class
        self.class.thumbnail_class
      end

      # Gets the thumbnail name for a filename.  'foo.jpg' becomes 'foo_thumbnail.jpg'
      def thumbnail_name_for(thumbnail = nil)
        return filename unless thumbnail
        basename, ext = filename.split '.'
        "#{basename}_#{thumbnail}.#{ext}"
      end

      # Creates or updates the thumbnail for the current attachment.
      def create_or_update_thumbnail(file_name_suffix, *size)
        returning thumbnail_class.find_or_initialize_by_thumbnail_and_parent_id(file_name_suffix.to_s, id) do |thumb|
          thumb.attributes = {
            :content_type    => content_type, 
            :filename        => thumbnail_name_for(file_name_suffix), 
            :attachment_data => resize_image_to(size)
          }
          thumb.save!
        end
      end

      # This method handles the uploaded file object.  If you set the field name to uploaded_data, you don't need
      # any special code in your controller.
      #
      #   <% form_for :attachment, :html => { :multipart => true } do |f| -%>
      #     <p><%= f.file_field :uploaded_data %></p>
      #     <p><%= submit_tag :Save %>
      #   <% end -%>
      #
      #   @attachment = Attachment.create! params[:attachment]
      def uploaded_data=(file_data)
        return nil if file_data.nil? || file_data.size == 0 
        self.content_type    = file_data.content_type.strip
        self.filename        = file_data.original_filename.strip
        self.attachment_data = file_data.read
      end

      # Sets the actual binary data.  This is typically called by uploaded_data=, but you can call this
      # manually if you're creating from the console.  This is also where the resizing occurs.
      def attachment_data=(data)
        if data.nil?
          @attachment_data = nil
          @save_attachment = false
          return nil
        end
        with_image data do |img|
          resized_img       = (attachment_options[:resize_to] && parent_id.nil?) ? 
            thumbnail_for_image(img, attachment_options[:resize_to]) : img
          data              = resized_img.to_blob
          self.width        = resized_img.columns if respond_to?(:width)
          self.height       = resized_img.rows    if respond_to?(:height)
          callback_with_args :after_resize, resized_img
        end if image?
        self.size = data.length
        @attachment_data = data
        @save_attachment = true
      end

      # Resizes a thumbnail.
      def resize_image_to(size)
        thumb = nil
        with_image do |img|
          thumb = thumbnail_for_image(img, size)
        end
        thumb
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

      def thumbnail_class
        self.class.thumbnail_class
      end

      protected
       # Performs the actual resizing operation for a thumbnail
        def thumbnail_for_image(img, size)
          size = size.first if size.is_a?(Array) && size.length == 1 && !size.first.is_a?(Fixnum)
          if size.is_a?(Fixnum) || (size.is_a?(Array) && size.first.is_a?(Fixnum))
            size = [size, size] if size.is_a?(Fixnum)
            img.thumbnail(size.first, size[1])
          else
            img.change_geometry(size.to_s) { |cols, rows, image| image.resize(cols, rows) }
          end
        end
        
        def sanitize_filename
          return unless filename
          # NOTE: File.basename doesn't work right with Windows paths on Unix
          # get only the filename, not the whole path
          filename.gsub!(/^.*(\\|\/)/, '')
        
          # Finally, replace all non alphanumeric, underscore or periods with underscore
          filename.gsub!(/[^\w\.\-]/, '_')
        end
        
        # creates default thumbnails for parent attachments
        def create_attachment_thumbnails
          return unless image?
          attachment_options[:thumbnails].each { |suffix, size| create_or_update_thumbnail(suffix, size) } unless !@save_attachment || attachment_options[:thumbnails].blank? || parent_id
          if @save_attachment
            @save_attachment = nil
            callback :after_attachment_saved
          end
        end
        
        # validates the size and content_type attributes according to the current model's options
        def attachment_attributes_valid?
          [:size, :content_type].each do |attr_name|
            enum = attachment_options[attr_name]
            errors.add attr_name, ActiveRecord::Errors.default_error_messages[:inclusion] unless enum.nil? || enum.include?(send(attr_name))
          end
        end
        
        # Yanked from ActiveRecord::Callbacks, modified so I can pass args to the callbacks besides self.
        # Only accept blocks, however
        def callback_with_args(method, arg = self)
          notify(method)

          result = nil
          callbacks_for(method).each do |callback|
            result = callback.call(self, arg)
            return false if result == false
          end

          return result
        end
    end
    
    # Methods for DB backed attachments
    module DbFileMethods
      def self.included(base) #:nodoc:
        base.belongs_to  :db_file
        base.before_save :save_to_storage # so the db_file_id can be set
      end

      # Gets the attachment data
      def attachment_data
        @attachment_data ||= db_file.data
      end

      protected          
        # Destroys the file.  Called in the after_destroy callback
        def destroy_file
          db_file.destroy if db_file
        end
        
        # Saves the data to the DbFile model
        def save_to_storage
          if @save_attachment
            (db_file || build_db_file).data = attachment_data
            db_file.save!
            self.db_file_id = db_file.id # needed for my own sanity, k thx
          end
          true
        end
    end
    
    # Methods for file system backed attachments
    module FileSystemMethods
      def self.included(base) #:nodoc:
        base.before_update :rename_file
        base.after_save    :save_to_storage # so the id can be part of the url
      end

      # Gets the attachment data
      def attachment_data
        filename = full_filename
        @attachment_data ||= File.file?(filename) ? File.read(filename) : nil

        return @attachment_data if @attachment_data
        File.open(filename, 'rb') do |file|
          @attachment_data = file.read
        end if File.file?(filename)
        @attachment_data
      end

      # Gets the full path to the filename in this format:
      #
      #   # This assumes a model name like MyModel
      #   # public/#{table_name} is the default filesystem path 
      #   RAILS_ROOT/public/my_models/5/blah.jpg
      #
      # Overwrite this method in your model to customize the filename.
      # The optional thumbnail argument will output the thumbnail's filename.
      def full_filename(thumbnail = nil)
        file_system_path = (thumbnail ? thumbnail_class : self).attachment_options[:file_system_path]
        File.join(RAILS_ROOT, file_system_path, (parent_id || id).to_s, thumbnail_name_for(thumbnail))
      end

      # Used as the base path that #public_filename strips off full_filename to create the public path
      def base_path
        @base_path ||= File.join(RAILS_ROOT, 'public')
      end

      # Gets the public path to the file
      # The optional thumbnail argument will output the thumbnail's filename.
      def public_filename(thumbnail = nil)
        full_filename(thumbnail).gsub %r(^#{Regexp.escape(base_path)}), ''
      end

      def filename=(value)
        @old_filename = full_filename unless filename.nil? || @old_filename
        write_attribute :filename, value
      end

      protected
        # Destroys the file.  Called in the after_destroy callback
        def destroy_file
          FileUtils.rm full_filename rescue nil
        end
        
        def rename_file
          return unless @old_filename && @old_filename != full_filename
          if @save_attachment && File.exists?(@old_filename)
            FileUtils.rm @old_filename
          elsif File.exists?(@old_filename)
            FileUtils.mv @old_filename, full_filename
          end
          @old_filename =  nil
          true
        end
        
        # Saves the file to the file system
        def save_to_storage
          if @save_attachment
            # TODO: This overwrites the file if it exists, maybe have an allow_overwrite option?
            FileUtils.mkdir_p(File.dirname(full_filename))
            
            # TODO Convert to streaming storage to prevent excessive memory usage
            # FileUtils.copy_stream is very efficient in regards to copies
            # OR - get the tmp filename for large files and do FileUtils.cp ? *agile*
            File.open(full_filename, "wb") do |file|
              file.write(attachment_data)
            end
          end
          @old_filename = nil
          true
        end
    end
  end
end
