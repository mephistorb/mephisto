class Admin::AssetsController < Admin::BaseController
  before_filter :find_asset, :except => [:index, :new, :create]

  def index
    @types  = params[:filter].blank? ? [] : params[:filter].keys
    @asset_pages = Paginator.new self, count_by_conditions, 20, params[:page]
    @assets = @types.any? ?
      site.assets.find_all_by_content_types(@types, :all, search_options) :
      site.assets.find(:all, search_options)
    @recent = []
    4.times { @recent << @assets.shift }
    @recent.compact!
    
    respond_to do |format|
      format.html
      format.js
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
      search_conditions.merge(:order => 'created_at desc', :limit => @asset_pages.items_per_page, :offset => @asset_pages.current.offset, :include => :site)
    end

    def search_conditions
      return @search_conditions if @search_conditions
      unless params[:q].blank?
        params[:q].downcase!
        params[:q] << '%'
      end
      
      @search_conditions =
        returning :conditions => [] do |options|
          unless params[:q].blank?
            params[:conditions] = { :title => true } if params[:conditions].blank?
            options[:conditions] << Asset.send(:sanitize_sql, ['(LOWER(assets.title) LIKE :q or LOWER(assets.filename) LIKE :q)', {:q => params[:q]}]) if params[:conditions].has_key?(:title)
            
            if params[:conditions].has_key?(:tags)
              options[:from] = "assets, taggings, tags"
              options[:conditions] << Asset.send(:sanitize_sql, 
                ["(assets.id = taggings.taggable_id and taggings.taggable_type = 'Asset' and taggings.tag_id = tags.id and tags.name IN (?))", Tag.parse(params[:q])])
            end
          end
        
          if options[:conditions].blank?
            options.delete(:conditions)
          else
            options[:conditions] = options[:conditions] * ' or '
          end
        end
    end
    
    def count_by_conditions
      type_conditions = @types.blank? ? nil : Asset.types_to_conditions(@types.dup).join(" OR ")
      @count_by_conditions ||= search_conditions[:conditions].blank? ? site.assets.count(:all, :conditions => type_conditions) :
        Asset.count_by_sql("SELECT COUNT(assets.id) FROM #{search_conditions[:from]  || 'assets'} WHERE site_id = #{site.id} #{type_conditions && "and #{type_conditions}"} AND #{search_conditions[:conditions]}")
    end
end
