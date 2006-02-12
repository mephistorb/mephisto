class Admin::BaseController < ApplicationController
  include AuthenticatedSystem
  before_filter :login_required

  def find_templates_and_resources!
    @templates, @resources = Asset.find(:all, :conditions => ['type in (?)', %w(Resource Template)], :order => 'filename').partition do |asset|
      asset.is_a? Template
    end
    @resources = @resources.sort_by { |r| r.full_path }
  end
end
