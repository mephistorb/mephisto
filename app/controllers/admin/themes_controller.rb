class Admin::ThemesController < Admin::BaseController
  @@theme_export_path   = RAILS_PATH + 'tmp/export'
  @@theme_content_types = %w(application/zip multipart/x-zip application/x-zip-compressed)
  cattr_accessor :theme_export_path, :theme_content_types
  before_filter :protect_action, :only => [:export, :change_to, :rollback]
  before_filter :find_theme, :only => [:preview_for, :export, :change_to, :show, :destroy]

  def preview_for
    send_file((@theme.preview.exist? ? @theme.preview : RAILS_PATH + 'public/images/mephisto/preview.png').to_s, :type => 'image/png', :disposition => 'inline')
  end

  def show
    respond_to do |format|
      format.js
    end
  end

  def export
    theme_site_path = temp_theme_path_for(params[:id])
    theme_zip_path  = theme_site_path   + "#{params[:id]}.zip"
    theme_zip_path.unlink if theme_zip_path.exist?
    @theme.export_as_zip params[:id], :to => theme_site_path
    theme_zip_path.exist? ? send_file(theme_zip_path.to_s, :stream => false) : raise("Error sending #{theme_zip_path.to_s} file")
  ensure
    theme_site_path.rmtree
  end
  
  def change_to
    site.change_theme_to @theme
    flash[:notice] = "Your theme has now been changed to '#{params[:id]}'"
    sweep_cache
    redirect_to :controller => 'design', :action => 'index'
  end

  def rollback
    site.rollback
    flash[:notice] = "Your theme has been rolled back"
    sweep_cache
    redirect_to :controller => 'design', :action => 'index'
  end

  def import
    return unless request.post? # If this is a GET, just render form.
    unless params[:theme] && params[:theme].size > 0 && theme_content_types.include?(params[:theme].content_type.strip)
      flash.now[:error] = "Invalid theme uploaded."
      return
    end
    filename = params[:theme].original_filename
    filename.gsub!(/(^.*(\\|\/))|(\.zip$)/, '')
    filename.gsub!(/[^\w\.\-]/, '_')
    begin
      theme_site_path = temp_theme_path_for(filename)
      zip_file        = theme_site_path + "temp.zip"
      File.open(zip_file, 'wb') { |f| f << params[:theme].read }
      site.import_theme zip_file, filename
      flash[:notice] = "The '#{filename}' theme has been imported."
      redirect_to :action => 'index'
    rescue
      flash.now[:error] = "Invalid theme uploaded: [#{$!.class.name}] #{$!}"
    ensure
      theme_site_path.rmtree
    end
  end

  def destroy
    if @theme.current?
      flash[:error] = "Cannot delete the current theme"
    else
      @index = site.themes.index(@theme)
      @theme.path.rmtree
      flash[:notice] = "The '#{params[:id]}' theme was deleted."
    end
    respond_to do |format|
      format.html { redirect_to :action => 'index' }
      format.js
    end
  end

  protected
    def find_theme
      show_404 unless @theme = params[:id] == 'current' ? site.theme : site.themes[params[:id]]
    end

    def temp_theme_path_for(prefix)
      returning theme_export_path + "site-#{site.id}/#{prefix}#{Time.now.utc.to_i.to_s.split('').sort_by { rand }}" do |path|
        FileUtils.mkdir_p path unless path.exist?
      end
    end

    def sweep_cache
      site.expire_cached_pages self, "Expired all referenced pages"
    end

    alias authorized? admin?
end
