class Admin::ThemesController < Admin::BaseController
  @@theme_export_path = RAILS_PATH + 'tmp/export'
  cattr_accessor :theme_export_path
  
  before_filter :find_theme, :only => [:preview_for, :export, :change_to]

  def preview_for
    send_file((@theme.preview.exist? ? @theme.preview : RAILS_PATH + 'public/images/mephisto/preview.png').to_s, :type => 'image/png', :disposition => 'inline')
  end

  def export
    theme_site_path = theme_export_path + "site-#{site.id}/#{params[:id]}#{Time.now.utc.to_i.to_s.split('').sort_by { rand }}"
    theme_zip_path  = theme_site_path   + "#{params[:id]}.zip"
    FileUtils.mkdir_p theme_site_path unless theme_site_path.exist?
    theme_zip_path.unlink if theme_zip_path.exist?
    @theme.export_as_zip params[:id], :to => theme_site_path
    theme_zip_path.exist? ? send_file(theme_zip_path.to_s, :stream => false) : raise("Error sending #{theme_zip_path.to_s} file")
  ensure
    theme_site_path.rmtree
  end
  
  def change_to
    site.change_theme_to @theme
    flash[:notice] = "Your theme has now been changed to '#{params[:id]}'"
    redirect_to :controller => 'design', :action => 'index'
  end
  
  protected
    def find_theme
      show_404 unless @theme = site.themes[params[:id]]
    end
end
