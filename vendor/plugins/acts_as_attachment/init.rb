begin
  require 'RMagick'
rescue LoadError
  # boo hoo no rmagick
end
ActiveRecord::Base.send(:include, Technoweenie::ActsAsAttachment)
