module Mephisto
  module Attachments
    module ResourceMethods
      NON_IMAGE_EXTNAMES = %w(.js .css).freeze
      def image?(path)
        !NON_IMAGE_EXTNAMES.include?(path.extname)
      end

      def content_type(path)
        case path.extname
          when '.js'           then 'text/javascript'
          when '.css'          then 'text/css'
          when '.png'          then 'image/png'
          when '.jpg', '.jpeg' then 'image/jpeg'
          when '.gif'          then 'image/gif'
        end
      end

      def [](filename)
        path = 
          case filename
            when /\.js$/i  then 'javascripts'
            when /\.css$/i then 'stylesheets'
            else                'images'
          end
          
        site.attachment_path + "#{path}/#{File.basename(filename.to_s)}"
      end
    end
  end
end