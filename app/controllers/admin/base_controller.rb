class Admin::BaseController < ApplicationController
  include AuthenticatedSystem
  before_filter :login_from_cookie
  before_filter :login_required, :except => :feed

  def find_templates_and_resources
    @resources, @templates = site.attachments.find_theme_files.partition do |asset|
      asset.is_a?(Resource)
    end
    @resources = @resources.sort_by { |r| r.full_filename }
    @images, @resources = @resources.partition { |r| r.image? }
  end
end
