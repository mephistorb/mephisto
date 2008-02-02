class Admin::AssetsController < Admin::BaseController
  member_actions.push(*%w(index new create latest search add_bucket clear_bucket edit update))
  skip_before_filter :login_required
  before_filter :find_asset, :except => [:index, :new, :create, :latest, :search, :upload, :clear_bucket]
  before_filter :login_required

  def index
    search_assets 24
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
    @assets = []
    params[:asset] ||= {} ; params[:asset_data] ||= []
    params[:asset].delete(:title) if params[:asset_data].size > 1
    params[:asset_data].each do |file|
      @assets << site.assets.build(params[:asset].merge(:uploaded_data => file, :user_id => current_user.id))
    end
    Asset.transaction { @assets.each &:save! }
    flash[:notice] = @assets.size == 1 ? "'#{CGI.escapeHTML @assets.first.title}' was uploaded." : "#{@assets.size} assets were uploaded."
    if @assets.size.zero? 
      @asset = Asset.new
      render :action => 'new'
    else
      redirect_to assets_path
    end
  rescue ActiveRecord::RecordInvalid => e
    @asset = e.record
    render :action => 'new'
  end

  def update
    @asset.attributes = params[:asset]
    @asset.save!
    redirect_to assets_path
  rescue ActiveRecord::RecordInvalid
    render :action => 'edit'
  end

  def latest
    @assets = site.assets.find(:all, :order => 'created_at desc', :limit => 6)
    render :update do |page|
      page['latest-assets'].replace_html :partial => 'widget', :collection => @assets, :locals => { :prefix => 'latest' }
    end
  end
  
  def search
    search_assets 6
    render :update do |page|
      page['spinner'].hide
        return page['search-assets'].replace_html(:partial => 'widget', :collection => @assets, :locals => { :prefix => 'search' }) if @assets.any?
        page['search-assets'].replace_html %(Couldn't find any matching assets.)
    end
  end

  def destroy
    @asset.destroy
    redirect_to assets_path
    (session[:bucket] || {}).delete(@asset.public_filename)
    flash[:notice] = "Deleted '#{@asset.filename}'"
  end

  # rjs
  def add_bucket
    if (session[:bucket] ||= {}).key?(@asset.public_filename)
      render :nothing => true and return
    end
    args = asset_image_args_for(@asset, :tiny, :title => "#{@asset.title} \n #{@asset.tags.join(', ')}")
    session[:bucket][@asset.public_filename] = args
  end

  def clear_bucket
    session[:bucket] = nil
  end

  protected
    def find_asset
      @asset = site.assets.find(params[:id])
    end

    def search_assets(limit)
      @types  = params[:filter].blank? ? [] : params[:filter].keys
      options = search_options.merge(:per_page => limit, :page => params[:page], :total_entries => count_by_conditions)

      @assets = @types.any? ?
        site.assets.paginate_by_content_types(@types, :all, options) :
        site.assets.paginate(options) 
    end

    def search_options
      search_conditions.merge(:order => 'created_at desc')
    end

    def search_conditions
      return @search_conditions if @search_conditions
      unless params[:q].blank?
        params[:q].downcase!
        params[:q] << '%'
      end
      
      @search_conditions =
        returning :conditions => [] do |options|
          options[:include] = []
          unless params[:q].blank?
            params[:conditions] = { :title => true, :tags => true } if params[:conditions].blank?
            if params[:conditions].has_key?(:title)
              options[:conditions] << Asset.send(:sanitize_sql, ['(LOWER(assets.title) LIKE :q or LOWER(assets.filename) LIKE :q)', {:q => params[:q]}])
            end
            
            if params[:conditions].has_key?(:tags)
              options[:include] << :tags
              options[:conditions] << Asset.send(:sanitize_sql, ["(taggings.taggable_type = 'Asset' and tags.name IN (?))", Tag.parse(params[:q].chomp("%"))])
            end
          end
        
          if options[:conditions].blank?
            options.delete(:conditions)
          else
            options[:conditions] *= ' OR ' 
          end
          
          options.delete(:include) if options[:include].empty?
        end
    end
    
    def count_by_conditions
      type_conditions = @types.blank? ? nil : Asset.types_to_conditions(@types.dup).join(" OR ")
      @count_by_conditions ||= search_conditions[:conditions].blank? ? site.assets.count(:all, :conditions => type_conditions) :
        Asset.count( 
        :joins =>  search_conditions[:joins], 
        :conditions => "site_id = #{site.id} #{type_conditions && "and #{type_conditions}"} AND #{search_conditions[:conditions]}", 
        :include => search_conditions[:include])
    end
    
    def allow_member?
      @asset && @asset.user_id.to_s == current_user.id.to_s
    end
end
