class Admin::TemplatesController < Admin::BaseController
  verify :params => :filename, :only => [:edit, :update],
         :add_flash   => { :error => 'Template required' },
         :redirect_to => { :action => 'index' }
  verify :method => :post, :params => :data, :only => :update,
         :add_flash   => { :error => 'Template required' },
         :redirect_to => { :action => 'edit' }

  def index
    redirect_to :controller => 'design'
  end

  def edit
    @tmpl = site.templates[params[:filename]]
  end

  def update
    site.templates.write(params[:filename], params[:data])
    Mephisto::SweeperMethods.expire_cached_pages "Expired all referenced pages", self, *CachedPage.find(:all)
    render :update do |page|
      page.call 'Flash.notice', 'Template updated successfully'
    end
  end

  def remove
    @tmpl = site.templates[params[:filename]]
    render :update do |page|
      if !@tmpl.file?
        page.flash.errors "File does not exist"
        page.visual_effect :fade, params[:context], :duration => 0.3
      elsif site.templates.custom.include?(@tmpl.basename.to_s)
        @tmpl.unlink
        page.visual_effect :fade, params[:context], :duration => 0.3
      else
        page.flash.errors "Cannot remove system template '#{params[:filename]}'"
      end
    end
  end
end
