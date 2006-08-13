class Admin::AssetsController < Admin::BaseController
  before_filter :find_asset, :except => [:index, :new, :create]

  def index
    @assets = site.assets.find(:all, :order => 'created_at desc', :limit => 20)
    @recent = []
    4.times { @recent << @assets.shift }
    @recent.compact!
  end
  
  def new
    @asset = Asset.new
  end

  def create
    @asset = site.assets.build(params[:asset])
    @asset.save!
    redirect_to assets_path
  end

  def update
    @asset.attributes = params[:asset]
    @asset.save!
    redirect_to assets_path
  end

  protected
    def find_asset
      @asset = site.assets.find(params[:id])
    end
end
