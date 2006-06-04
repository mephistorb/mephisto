begin
  require 'RMagick'
rescue
  # boo hoo no rmagick
end
ActiveRecord::Base.send(:include, Technoweenie::ActsAsAttachment)
