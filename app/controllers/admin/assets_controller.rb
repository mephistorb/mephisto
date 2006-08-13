class Admin::AssetsController < Admin::BaseController
  def index
    @assets = Asset.find(:all, :order => 'created_at desc', :limit => 20)
    @recent = []
    4.times { @recent << @assets.shift }
    @recent.uniq!
  end
  
  def create
    @asset = site.assets.build(params[:asset])
    @asset.save!
    redirect_to assets_path
  end
end
