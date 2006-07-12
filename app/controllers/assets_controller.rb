class AssetsController < ApplicationController
  session :off
  caches_page_with_references :show
  def show
    content_type = Attachment.content_path.index(params[:dir])
    @asset       = content_type ? 
      Resource.find_by_content_type_and_filename(content_type, params[:path].first) : 
      Resource.find_image(params[:path].first)
    self.cached_references << @asset

    if @asset.nil?
      show_404
    elsif @asset.image?
      send_data @asset.attachment_data, :filename => @asset.filename, :type => @asset.content_type, :disposition => 'inline'
    else
      headers['Content-Type'] = @asset.content_type
      render :text => @asset.attachment_data
    end
  end
end
