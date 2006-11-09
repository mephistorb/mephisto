module Technoweenie # :nodoc:
  module ActsAsAttachment # :nodoc:
    module InstanceMethods
      def self.included(base)
        base.class_eval do
          protected
          if base.attachment_attributes[:parent_id]
            def find_or_initialize_thumbnail(file_name_suffix)
              thumbnail_class.find_or_initialize_by_thumbnail_and_parent_id(file_name_suffix.to_s, id)
            end
          else
            def find_or_initialize_thumbnail(file_name_suffix)
              thumbnail_class.find_or_initialize_by_thumbnail(file_name_suffix.to_s)
            end
          end
        end
      end

      # Checks whether the attachment's content type is an image content type
      def image?
        self.class.image?(content_type.to_s.strip)
      end
      
      def thumbnailable?
        image? && attachment_attributes[:parent_id]
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
        thumbnailable? || raise(ThumbnailError.new("Can't create a thumbnail if the content type is not an image or there is no parent_id column"))
        returning find_or_initialize_thumbnail(file_name_suffix) do |thumb|
          resized_image = resize_image_to(size)
          return if resized_image.nil?
          thumb.attributes = {
            :content_type    => content_type, 
            :filename        => thumbnail_name_for(file_name_suffix), 
            :attachment_data => resized_image
          }
          callback_with_args :before_thumbnail_saved, thumb
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
          resized_img       = (attachment_options[:resize_to] && (!attachment_attributes(:parent_id) || parent_id.nil?)) ? 
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

      # Returns the width/height in a suitable format for the image_tag helper: (100x100)
      def image_size
        [width.to_s, height.to_s] * 'x'
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
          if thumbnailable? && @save_attachment && !attachment_options[:thumbnails].blank? && parent_id.nil?
            attachment_options[:thumbnails].each { |suffix, size| create_or_update_thumbnail(suffix, size) }
          end
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
  end
end