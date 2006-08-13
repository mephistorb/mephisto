class Admin::AssetsController < Admin::BaseController
  def index
  end
  
  def create
    @asset = site.assets.build(params[:asset])
    @asset.save!
    redirect_to assets_path
  end
end
