class Admin::SitesController < Admin::BaseController

  before_filter :admin_required
  member_actions.push *%W(index show new destroy create)
  
  def index
    @sites = Site.search_by_host_or_title params[:search_string] do
      Site.paginate(:page => params[:page], :per_page => params[:per_page], :order => 'id')
    end
  end

  def show
    @site = Site.find(params[:id])
  end

  def new
    @site = Site.new
  end

  def create
    @site = Site.new(params[:site])
    if @site.save
      flash[:notice] = "Site #{@site.host} was successfully created."
      redirect_to :action => 'index'
    else
      flash[:error] = "Failed to create site."
      render :action => "new"
    end
  end

  # Not sure about having an edit / update, maybe allow the change of a host name?
  # def edit
  #   @site = Site.find(params[:id])
  # end
  # 
  # def update
  #   @site = Site.find(params[:id])
  #   if @site.update_attributes(params[:site])
  #     flash[:notice] = "Site #{@site.host} was successfully updated."
  #     redirect_to :action => 'index'
  #   else
  #     render :action => "edit"
  #   end
  # end

  def destroy
    @site = Site.find(params[:id])
    if @site.destroy
      flash[:notice] = "Site removed."
      redirect_to :action => 'index'
    else
      flash[:error] = "Failed to remove site #{@site.host}. Check file permissions."
      render :action => 'show'
    end
  end
  
  private
    def admin_required
      current_user.admin? ? true : not_allowed
    end
    
    def not_allowed
      flash[:error] = "Only global administrators can manage sites."
      redirect_to :controller => "/account", :action => :login
    end
    
end
