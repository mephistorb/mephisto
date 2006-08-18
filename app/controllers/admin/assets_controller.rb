class Admin::AssetsController < Admin::BaseController
  before_filter :find_asset, :except => [:index, :new, :create]

  def index
    options = { :order => 'created_at desc', :limit => 20 }
    @types  = params[:filter].blank? ? [] : params[:filter].keys
    @assets = @types.any? ?
      site.assets.find_all_by_content_types(@types, :all, options) :
      site.assets.find(:all, options)
    @recent = []
    4.times { @recent << @assets.shift }
    @recent.compact!
    
    respond_to do |format|
      format.js
      format.html
    end
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
