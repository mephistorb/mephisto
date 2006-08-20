class Attachment < ActiveRecord::Base
  @@content_path = { 'text/css' => 'stylesheets', 'text/javascript' => 'javascripts' }.freeze
  @@content_ext  = { 'text/css' => '.css',        'text/javascript' => '.js' }.freeze
  cattr_accessor :content_path, :content_ext

  belongs_to :site
  validates_presence_of   :site
  validates_uniqueness_of :filename, :scope => :site_id
  acts_as_attachment :storage => :file_system
end