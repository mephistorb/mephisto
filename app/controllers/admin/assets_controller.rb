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

      returning :order => 'created_at desc', :limit => 20, :conditions => [] do |options|
        unless params[:q].blank?
          params[:conditions] = { :title => true } if params[:conditions].blank?
          options[:conditions] << Asset.send(:sanitize_sql, ['(LOWER(title) LIKE :q or LOWER(filename) LIKE :q)', {:q => params[:q]}]) if params[:conditions].has_key?(:title)
          
          if params[:conditions].has_key?(:tags)
            options[:joins] = "inner join taggings on taggings.taggable_id = assets.id and taggings.taggable_type = 'Asset' inner join tags on taggings.tag_id = tags.id"
            options[:conditions] << Asset.send(:sanitize_sql, ['(tags.name IN (?))', Tag.parse(params[:q])])
          end
        end

        if options[:conditions].blank?
          options.delete(:conditions)
        else
          options[:conditions] = options[:conditions] * ' or '
        end
      end
    end
end
