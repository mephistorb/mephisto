class AssetsController < ApplicationController
  session :off
  caches_page_with_references :show
  def show
    @asset = Attachment.find_by_full_path((params[:dir] ? params[:path].dup.unshift(params[:dir]) : params[:path]).join('/'))
    self.cached_references << @asset

    if @asset.image?
      breakpoint
      send_data @asset.data, :filename => @asset.filename, :type => @asset.content_type, :disposition => 'inline'
    else
      headers['Content-Type'] = @asset.content_type
      render :text => @asset.data
    end
  end
end
