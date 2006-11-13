module Technoweenie # :nodoc:
  module ActsAsAttachment # :nodoc:
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
      def with_image(data, &block)
        begin
          binary_data = data.is_a?(Magick::Image) ? data : Magick::Image::from_blob(data).first unless !Object.const_defined?(:Magick)
        rescue
          # Log the failure to load the image.  This should match ::Magick::ImageMagickError
          # but that would cause acts_as_attachment to require rmagick.
          logger.debug("Exception working with image: #{$!}")
          binary_data = nil
        end
        block.call binary_data if block && binary_data
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

      # Callback before a thumbnail is saved.  Use this to pass any necessary extra attributes that may be required.
      #
      #   class Foo < ActiveRecord::Base
      #     acts_as_attachment
      #     before_thumbnail_saved do |record, thumbnail|
      #       ...
      #     end
      #   end
      def before_thumbnail_saved(&block)
        write_inheritable_array(:before_thumbnail_saved, [block])
      end

      # Get the thumbnail class, which is the current attachment class by default.
      # Configure this with the :thumbnail_class option.
      def thumbnail_class
        attachment_options[:thumbnail_class] = attachment_options[:thumbnail_class].constantize unless attachment_options[:thumbnail_class].is_a?(Class)
        attachment_options[:thumbnail_class]
      end
    end
  end
end