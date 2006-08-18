class Admin::AssetsController < Admin::BaseController
  before_filter :find_asset, :except => [:index, :new, :create]

  def index
    @types  = params[:filter].blank? ? [] : params[:filter].keys
    @assets = @types.any? ?
      site.assets.find_all_by_content_types(@types, :all, search_options) :
      site.assets.find(:all, search_options)
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
    
    def search_options
      unless params[:q].blank?
        params[:q].downcase!
        params[:q] << '%'
      end
      returning :order => 'created_at desc', :limit => 20 do |options|
        options[:conditions] = ['LOWER(title) LIKE :q or LOWER(filename) LIKE :q', {:q => params[:q]}] unless params[:q].blank?
      end
    end
end
