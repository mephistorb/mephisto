# Requires Flickr.rb (http://redgreenblu.com/flickr/flickr.rb)
#
# Converts <filter:flickr /> into Images from flickr
# Attributes:;
#  <tt>img</tt> Flickr image id
#  <tt>size</tt> thumb, square, large
#  <tt>style</tt> CSS styles rendered inline
#  <tt>caption</tt> Custom caption, defaults to photos caption on Flickr
#  <tt>title</tt> Custom title, defaults to photos title on Flickr
#  <tt>alt</tt> Custom alt, defaults to image's title
#
# Extracted from Typo (http://typosphere.org)
#
class FlickrMacro
  KEY = '84f652422f05b96b29b9a960e0081c50'
  
  def self.filter(attributes, inner_text = "", text="")
    RAILS_DEFAULT_LOGGER.info("ATTRIBUTES: #{attributes}")
     img     = attributes[:img]
     size    = attributes[:size] || "square"
     style   = attributes[:style]
     caption = attributes[:caption]
     title   = attributes[:title]
     alt     = attributes[:alt]

     flickr = Flickr.new(KEY)
     flickrimage = Flickr::Photo.new(img)
     sizes = flickrimage.sizes

     details = sizes.find {|s| s['label'].downcase == size.downcase } || sizes.first
     width = details['width']
     height = details['height']
     imageurl = details['source']
     imagelink = flickrimage.url

     caption ||= flickrimage.description
     title ||= flickrimage.title
     alt ||= title

     if(caption.blank?)
       captioncode=""
     else
       captioncode = "<p class=\"caption\" style=\"width:#{width}px\">#{caption}</p>"
     end

     "<div style=\"#{style}\" class=\"flickrplugin\"><a href=\"#{imagelink}\"><img src=\"#{imageurl}\" width=\"#{width}\" height=\"#{height}\" alt=\"#{alt}\" title=\"#{title}\"/></a>#{captioncode}</div>"
    end

end




