class Resources < Attachments
  NON_IMAGE_EXTNAMES = %w(.js .css)
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
      when '.swf'          then 'application/x-shockwave-flash'
      when '.ico'          then 'image/x-icon'
    end
  end
  
  def [](filename)
    path = 
      case filename
        when /\.js$/i  then 'javascripts'
        when /\.css$/i then 'stylesheets'
        else                'images'
      end
      
    theme.path + "#{path}/#{File.basename(filename.to_s)}"
  end
end