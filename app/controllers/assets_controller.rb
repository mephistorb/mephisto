class AssetsController < ApplicationController
  def show
    params[:path].shift(params[:dir]) if params[:dir]
    @asset = Attachment.find_by_full_path params[:path].join('/')
    if @asset.image?
      send_data @asset.data, :filename => @asset.filename, :type => @asset.content_type, :disposition => 'inline'
    else
      headers['Content-Type'] = @asset.content_type
      render :text => @asset.data
    end
  end
end
