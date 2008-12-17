# SafeERB

require 'safe_erb/common'
require 'safe_erb/tag_helper'
require 'safe_erb/erb_extensions'
require 'safe_erb/action_view_extensions'

if Rails::VERSION::MAJOR >= 2
  require 'safe_erb/rails_2'
else
  require 'safe_erb/rails_1'
end

if defined?(ActiveRecord)
  adapter = ActiveRecord::Base.configurations[Rails.env]['adapter']
  file = File.join(File.dirname(__FILE__), 'safe_erb', "#{adapter}_fix.rb")
  if File.exists?(file)
    ActiveRecord::Base.connection # Make sure our adapter classes are loaded.
    require "safe_erb/#{adapter}_fix"
  end
end
